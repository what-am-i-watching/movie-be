class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @movie = Movie.find(params[:id])
    @enriched_movie = MovieDataEnricher.enrich_with_user_data(@movie, current_user)

    render json: { movie: @enriched_movie }, status: :ok
  end

  def create
    @movie = Movie.find_by(tmdb_id: movie_params[:tmdb_id])

    if @movie
      @enriched_movie = MovieDataEnricher.enrich_with_user_data(@movie, current_user)
      render json: { movie: @enriched_movie }, status: :ok
    else
      @movie = Movie.create(movie_params)

      if @movie.persisted?
        @enriched_movie = MovieDataEnricher.enrich_with_user_data(@movie, current_user)
        render json: { movie: @enriched_movie }, status: :created
      else
        render json: @movie.errors, status: :unprocessable_entity
      end
    end
  end

  def search
    if params[:query].present?
      @movie_results = MovieService.search_movies(params[:query])
      @movies = @movie_results[:results] || []

      @show_results = ShowsService.search_shows(params[:query])
      @shows = @show_results[:results] || []

      @all_results = (@movies + @shows).sort_by { |item| -item[:popularity] }

      @enriched_results = MovieDataEnricher.enrich_collection(@all_results, current_user)

      # Do we need pagination? Or maybe a limit sent to the api?
      render json: { movies: @enriched_results }, status: :ok

    else
      render json: { movies: [] }, status: :ok
    end
  rescue StandardError => e
    # TODO: Test error handling for the API call
    Rails.logger.error "MovieService API Error: #{e.message}"
    render json: { error: "Failed to fetch movies", details: e.message }, status: :internal_server_error
  end

  def popular
    @movie_results = MovieService.popular_movies()
    @movies = @movie_results[:results] || []

    @enriched_movies = MovieDataEnricher.enrich_collection(@movies, current_user)

    render json: { movies: @enriched_movies }, status: :ok
  rescue StandardError => e
    # TODO: Test error handling for the API call
    Rails.logger.error "MovieService API Error: #{e.message}"
    render json: { error: "Failed to fetch movies", details: e.message }, status: :internal_server_error
  end

  def details
    tmdb_id = params[:tmdb_id]
    return render json: { error: "tmdb_id parameter is required" }, status: :bad_request if tmdb_id.blank?

    # Parse is_movie: defaults to true unless explicitly "false"
    is_movie = params[:is_movie].to_s.downcase != "false"

    @movie_data = MovieService.movie_details(tmdb_id, is_movie: is_movie)

    if @movie_data[:error]
      return render json: { error: @movie_data[:error] }, status: :unprocessable_entity
    end

    @enriched_movie = MovieDataEnricher.enrich_with_user_data(@movie_data, current_user)

    # Ensure is_movie is set if not already determined
    unless @enriched_movie.key?(:is_movie)
      @enriched_movie[:is_movie] = @enriched_movie.key?(:original_title) || is_movie
    end

    render json: { movie: @enriched_movie }, status: :ok
  rescue StandardError => e
    Rails.logger.error "MovieService API Error: #{e.message}"
    render json: { error: "Failed to fetch movie details", details: e.message }, status: :internal_server_error
  end

  private

  def movie_params
    params.expect(movie: [ :title, :tmdb_id, :release_year, :poster_url, :is_movie ])
  end
end
