class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @movie = Movie.find(params[:id])

    render json: @movie, status: :ok
  end

  def create
    @movie = Movie.find_or_create_by(movie_params)

    if @movie.save
      render json: @movie, status: :created, location: @movie
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  def search
    if params[:query].present?
      @movie_results = MovieService.search_movies(params[:query])
      @movies = @movie_results[:results] || []

      @show_results = ShowsService.search_shows(params[:query])
      @shows = @show_results[:results] || []

      @all_results = (@movies + @shows).sort_by { |item| -item[:popularity] }

      @all_results.each do |movie|
        @db_movie = Movie.find_by(tmdb_id: movie[:id])
        if @db_movie
          @user_movie = current_user.user_movies.find_by(movie_id: @db_movie.id)
          if @user_movie
            movie[:in_list] = true
            movie[:status] = @user_movie.status
            movie[:rating] = @user_movie.rating
            movie[:notes] = @user_movie.notes
            movie[:progress_notes] = @user_movie.progress_notes
          else
            movie[:in_list] = false
          end
        else
          movie[:in_list] = false
        end
        movie[:is_movie] = movie.key?(:original_title)
      end

      # Do we need pagination? Or maybe a limit sent to the api?
      serialized_movies = MovieSerializer.new(@all_results, is_collection: true).serializable_hash

      # Send over array tmdb_id's to Grant's service for ranking

      render json: { movies: serialized_movies[:data].map { |h| h[:attributes] } }, status: :ok

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
    @movies.each do |movie|
      @db_movie = Movie.find_by(tmdb_id: movie[:id])
      if @db_movie
        @user_movie = current_user.user_movies.find_by(movie_id: @db_movie.id)
        if @user_movie
          movie[:in_list] = true
          movie[:status] = @user_movie.status
          movie[:rating] = @user_movie.rating
          movie[:notes] = @user_movie.notes
          movie[:progress_notes] = @user_movie.progress_notes
        end
      end
    end
    serialized_movies = MovieSerializer.new(@movies, is_collection: true).serializable_hash
    render json: { movies: serialized_movies[:data].map { |h| h[:attributes] } }, status: :ok
  end

  private

  def movie_params
    params.expect(movie: [ :title, :tmdb_id, :release_year, :poster_url ])
  end
end
