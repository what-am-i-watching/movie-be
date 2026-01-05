class MoviesController < ApplicationController
  def index
  end

  def show
  end

  def search
    if params[:query].present?
      @search_results = MovieService.search_movies(params[:query])
      @movies = @search_results[:results] || []

      # Do we need pagination? Or maybe a limit sent to the api?
      serialized_movies = MovieSerializer.new(@movies, is_collection: true).serializable_hash

      render json: { movies: serialized_movies[:data].map { |h| h[:attributes] } }, status: :ok

    else
      render json: { movies: [] }, status: :ok
    end
  rescue StandardError => e
    # TODO: Test error handling for the API call
    Rails.logger.error "MovieService API Error: #{e.message}"
    render json: { error: "Failed to fetch movies", details: e.message }, status: :internal_server_error
  end
end
