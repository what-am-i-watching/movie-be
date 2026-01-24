class UserMoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    user_movies = current_user.user_movies.includes(:movie) || []

    movies = user_movies.map(&:movie).compact
    enriched_movies = movies.map { |movie| MovieDataEnricher.enrich_with_user_data(movie, current_user) }

    render json: { user_movies: enriched_movies }, status: :ok
  end

  def create
    @user_movie = current_user.user_movies.find_by({ movie_id: user_movie_params["movie_id"], user_id: current_user["id"] })
    if @user_movie
      @user_movie.update(user_movie_params)
      # NOTE: since we show by create date, the user watched order is off
    else
      @user_movie = current_user.user_movies.find_or_create_by(user_movie_params)
    end

    if @user_movie.save
      @enriched_movie = MovieDataEnricher.enrich_with_user_data(@user_movie.movie, current_user)
      render json: { user_movie: @enriched_movie }, status: :created
    else
      render json: @user_movie.errors, status: :unprocessable_entity
    end
  end

  def destroy
    user_movie = UserMovie.find(params["id"])
    user_movie.destroy
  end

  private

  def user_movie_params
    params.expect(user_movie: [ :movie_id, :notes, :rating, :status, :progress_notes ])
  end
end
