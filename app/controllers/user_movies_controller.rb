class UserMoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_movies = current_user.user_movies || []

    render json: { user_movies: @user_movies }, status: :ok
  end

  def create
    @user_movie = current_user.user_movies.find_or_create_by(user_movie_params)

    if @user_movie.save
      render json: @user_movie, status: :created, location: @user_movie
    else
      render json: @user_movie.errors, status: :unprocessable_entity
    end
  end

  private

  def user_movie_params
    params.expect(user_movie: [ :movie_id, :notes, :rating, :watched ])
  end
end
