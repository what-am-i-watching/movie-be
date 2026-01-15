class UserMoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    user_movies = current_user.user_movies.includes(:movie) || []

    render json: { user_movies: user_movies.as_json(include: :movie) }, status: :ok
  end

  def create
    if
      @user_movie = current_user.user_movies.find_by({movie_id: user_movie_params["movie_id"], user_id: current_user["id"]})
      @user_movie.update(user_movie_params)
      # NOTE: since we show by create date, the user watched order is off
    else
      @user_movie = current_user.user_movies.find_or_create_by(user_movie_params)
    end


    if @user_movie.save
      render json: @user_movie, status: :created, location: @user_movie
    else
      render json: @user_movie.errors, status: :unprocessable_entity
    end
  end

  def destroy
    user_movie = UserMovie.find(params['id'])
    user_movie.destroy
  end

  private

  def user_movie_params
    params.expect(user_movie: [ :movie_id, :notes, :rating, :watched ])
  end
end
