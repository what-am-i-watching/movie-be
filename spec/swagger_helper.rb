# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'What Am I Watching? API',
        version: '1.0.0',
        description: "REST API for managing movies and TV shows watchlists. Supports user authentication (JWT), movie search and details via [The Movie Database (TMDB)](https://www.themoviedb.org), and user-specific lists with watch status, ratings, and notes.\n\n**Attribution:** This product uses the TMDB API but is not endorsed or certified by TMDB.",
        contact: {
          name: 'What Am I Watching?',
          url: 'https://whatamiwatching.info',
          email: 'whatamiwatching.info@gmail.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://whatamiwatching.info',
          description: 'Production server'
        }
      ],
      tags: [
        { name: 'Authentication', description: 'User registration, sign in/out, password reset, and current user' },
        { name: 'Movies', description: 'Search, popular, details, create, and fetch movies/TV shows by ID' },
        { name: 'User Movies', description: 'List, add, and remove movies/shows from the user\'s watchlist' }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtained from POST /users/sign_in endpoint. Include the token in the Authorization header as: Bearer {token}'
          }
        },
        schemas: {
          Movie: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                description: 'Database ID',
                nullable: true,
                example: 1
              },
              tmdb_id: {
                type: :integer,
                description: 'TMDB (The Movie Database) ID',
                example: 603
              },
              title: {
                type: :string,
                description: 'Movie or TV show title',
                example: 'The Matrix'
              },
              release_date: {
                type: :string,
                format: :date,
                nullable: true,
                description: 'Release date (movies) or first air date (TV shows)',
                example: '1999-03-31'
              },
              poster_path: {
                type: :string,
                nullable: true,
                description: 'Poster image path/URL',
                example: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg'
              },
              is_movie: {
                type: :boolean,
                description: 'True if movie, false if TV show',
                example: true
              },
              in_list: {
                type: :boolean,
                description: 'Whether this movie/show is in the user\'s list',
                example: false
              },
              user_movie_id: {
                type: :integer,
                nullable: true,
                description: 'User movie association ID (if in_list is true)',
                example: 5
              },
              status: {
                type: :string,
                nullable: true,
                description: 'User watch status (to_watch, watching, watched) if in_list is true, otherwise TMDB release status',
                example: 'to_watch'
              },
              tmdb_status: {
                type: :string,
                nullable: true,
                description: 'TMDB release status (e.g., "Released", "Post Production") - only present when movie is not in user list',
                example: 'Released'
              },
              rating: {
                type: :integer,
                nullable: true,
                description: 'User rating (only present if in_list is true)',
                example: 5
              },
              notes: {
                type: :string,
                nullable: true,
                description: 'User notes (only present if in_list is true)',
                example: 'Great movie!'
              },
              progress_notes: {
                type: :string,
                nullable: true,
                description: 'Progress notes for TV shows (only present if in_list is true)',
                example: 'On season 2, episode 4'
              },
              overview: {
                type: :string,
                nullable: true,
                description: 'Plot overview/synopsis',
                example: 'A computer hacker learns about the true nature of reality...'
              },
              popularity: {
                type: :number,
                nullable: true,
                description: 'Popularity score from TMDB',
                example: 85.5
              },
              adult: {
                type: :boolean,
                nullable: true,
                description: 'Whether the content is marked as adult',
                example: false
              },
              backdrop_path: {
                type: :string,
                nullable: true,
                description: 'Backdrop image path/URL',
                example: '/r8FD6CC3GgjWaGVkZh00AcedfpA.jpg'
              },
              genre_ids: {
                type: :array,
                items: { type: :integer },
                nullable: true,
                description: 'Array of genre IDs from TMDB',
                example: [ 18, 878, 9648 ]
              },
              original_language: {
                type: :string,
                nullable: true,
                description: 'Original language code (e.g., "en", "es")',
                example: 'en'
              },
              original_title: {
                type: :string,
                nullable: true,
                description: 'Original title (may differ from localized title)',
                example: 'Arrival'
              },
              video: {
                type: :boolean,
                nullable: true,
                description: 'Whether the content has video (typically false for movies)',
                example: false
              },
              vote_average: {
                type: :number,
                nullable: true,
                description: 'Average vote rating from TMDB',
                example: 7.623
              },
              vote_count: {
                type: :integer,
                nullable: true,
                description: 'Number of votes on TMDB',
                example: 18910
              }
            }
          },
          User: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                description: 'User ID',
                example: 1
              },
              email: {
                type: :string,
                format: :email,
                description: 'User email address',
                example: 'user@example.com'
              },
              created_at: {
                type: :string,
                format: :date_time,
                description: 'Account creation timestamp',
                example: '2024-01-01T00:00:00.000Z'
              },
              updated_at: {
                type: :string,
                format: :date_time,
                description: 'Last update timestamp',
                example: '2024-01-01T00:00:00.000Z'
              },
              jti: {
                type: :string,
                description: 'JWT ID for token management',
                example: 'abc123'
              }
            },
            required: [ 'id', 'email' ]
          },
          Error: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: 'Error message',
                example: 'An error occurred'
              },
              details: {
                type: :string,
                nullable: true,
                description: 'Additional error details',
                example: 'More specific error information'
              }
            },
            required: [ 'error' ]
          },
          ValidationErrors: {
            type: :object,
            description: 'ActiveModel::Errors format - errors are keyed by field name',
            additionalProperties: {
              type: :array,
              items: { type: :string }
            },
            example: {
              field_name: [ 'error message 1', 'error message 2' ]
            }
          }
        }
      }
      # Security is applied per endpoint, not globally
      # Use security [bearerAuth: []] in endpoint specs that require authentication
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
