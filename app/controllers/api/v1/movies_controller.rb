class Api::V1::MoviesController < Api::V1::BaseController
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

      render_success(
        data: { movies: serialized_movies[:data].map { |h| h[:attributes] } }
      )
    else
      render_success(data: { movies: [] })
    end
  rescue StandardError => e
    Rails.logger.error "MovieService API Error: #{e.message}"
    render_error(
      message: "Failed to fetch movies",
      errors: [ e.message ],
      status: :internal_server_error
    )
  end
end
