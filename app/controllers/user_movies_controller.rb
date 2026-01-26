class UserMoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    user_movies = current_user.user_movies.includes(:movie)
    movies = user_movies.map(&:movie).compact
    enriched_movies = movies.map { |movie| MovieDataEnricher.enrich_with_user_data(movie, current_user) }

    render json: { user_movies: enriched_movies }, status: :ok
  end

  def create
    user_movie = current_user.user_movies.find_or_initialize_by(movie_id: user_movie_params[:movie_id])
    user_movie.assign_attributes(user_movie_params)

    if user_movie.save
      enriched_movie = MovieDataEnricher.enrich_with_user_data(user_movie.movie, current_user)
      render json: { user_movie: enriched_movie }, status: :created
    else
      render json: { errors: user_movie.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def destroy
    user_movie = current_user.user_movies.find(params[:id])
    user_movie.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User movie not found" }, status: :not_found
  end

  private

  def user_movie_params
    params.expect(user_movie: [ :movie_id, :notes, :rating, :status, :progress_notes ])
  end
end
