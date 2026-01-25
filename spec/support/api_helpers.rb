# frozen_string_literal: true

module ApiHelpers
  # Helper method to get authentication headers for swagger documentation
  def auth_header
    {
      name: 'Authorization',
      in: :header,
      required: true,
      schema: {
        type: :string,
        example: 'Bearer eyJhbGciOiJIUzI1NiJ9...'
      },
      description: 'JWT token obtained from POST /users/sign_in'
    }
  end

  def create_test_user(email: 'test@example.com', password: 'password123')
    User.create!(
      email: email,
      password: password,
      password_confirmation: password
    )
  end

  def authenticated_headers(user)
    auth_headers(user)
  end

  def create_test_movie(attributes = {})
    Movie.create!({
      title: 'Test Movie',
      tmdb_id: 12345,
      release_year: 2020,
      poster_url: 'https://example.com/poster.jpg',
      is_movie: true
    }.merge(attributes))
  end

  def create_test_user_movie(user:, movie: nil, **attributes)
    movie ||= create_test_movie
    UserMovie.create!({
      user: user,
      movie: movie,
      status: :to_watch
    }.merge(attributes))
  end

  # Schema helpers for OpenAPI documentation
  def error_schema
    {
      type: :object,
      properties: {
        error: {
          type: :string,
          description: 'Error message'
        },
        details: {
          type: :string,
          description: 'Additional error details (optional)'
        }
      },
      required: [ 'error' ]
    }
  end

  def validation_error_schema
    {
      type: :object,
      properties: {
        errors: {
          type: :object,
          description: 'Validation errors by field'
        }
      }
    }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
