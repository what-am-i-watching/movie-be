class MoviesController < ApplicationController
  before_action :authenticate_user!

  def show
    movie = Movie.find(params[:id])
    enriched_movie = MovieDataEnricher.enrich_with_user_data(movie, current_user)

    render json: { movie: enriched_movie }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movie not found" }, status: :not_found
  end

  def create
    movie = Movie.find_by(tmdb_id: movie_params[:tmdb_id])

    if movie
      enriched_movie = MovieDataEnricher.enrich_with_user_data(movie, current_user)
      render json: { movie: enriched_movie }, status: :ok
    else
      movie = Movie.new(movie_params)

      if movie.save
        enriched_movie = MovieDataEnricher.enrich_with_user_data(movie, current_user)
        render json: { movie: enriched_movie }, status: :created
      else
        render json: { errors: movie.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition: another request created the movie between find_by and create
    movie = Movie.find_by(tmdb_id: movie_params[:tmdb_id])
    return render json: { error: "Movie not found after creation" }, status: :not_found unless movie

    enriched_movie = MovieDataEnricher.enrich_with_user_data(movie, current_user)
    render json: { movie: enriched_movie }, status: :ok
  end

  def search
    return render json: { movies: [] }, status: :ok unless params[:query].present?

    movie_results = MovieService.search_movies(params[:query])
    movies = movie_results[:results] || []

    show_results = ShowsService.search_shows(params[:query])
    shows = show_results[:results] || []

    all_results = (movies + shows).sort_by { |item| -(item[:popularity] || 0) }

    enriched_results = MovieDataEnricher.enrich_collection(all_results, current_user)

    render json: { movies: enriched_results }, status: :ok
  rescue StandardError => e
    handle_api_error(e, "Failed to fetch movies")
  end

  def popular
    movie_results = MovieService.popular_movies
    movies = movie_results[:results] || []

    enriched_movies = MovieDataEnricher.enrich_collection(movies, current_user)

    render json: { movies: enriched_movies }, status: :ok
  rescue StandardError => e
    handle_api_error(e, "Failed to fetch movies")
  end

  def details
    tmdb_id = params[:tmdb_id]
    return render json: { error: "tmdb_id parameter is required" }, status: :bad_request if tmdb_id.blank?

    is_movie = parse_is_movie_param

    movie_data = MovieService.movie_details(tmdb_id, is_movie: is_movie)

    if movie_data[:error]
      return render json: { error: movie_data[:error] }, status: :unprocessable_entity
    end

    enriched_movie = MovieDataEnricher.enrich_with_user_data(movie_data, current_user)

    # Ensure is_movie is set if not already determined
    enriched_movie[:is_movie] ||= enriched_movie.key?(:original_title) || is_movie

    render json: { movie: enriched_movie }, status: :ok
  rescue StandardError => e
    handle_api_error(e, "Failed to fetch movie details")
  end

  private

  def movie_params
    params.expect(movie: [ :title, :tmdb_id, :release_date, :poster_url, :is_movie ])
  end

  def parse_is_movie_param
    # Defaults to true unless explicitly "false"
    params[:is_movie].to_s.downcase != "false"
  end

  def handle_api_error(error, message)
    Rails.logger.error "MovieService API Error: #{error.message}"
    Rails.logger.error error.backtrace.join("\n") if Rails.env.development?

    render json: {
      error: message,
      details: Rails.env.development? ? error.message : nil
    }, status: :internal_server_error
  end
end
