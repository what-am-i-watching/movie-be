# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Movies::Details', type: :request do
  path '/movies/details/{tmdb_id}' do
    get 'Get movie or TV show details' do
      tags 'Movies'
      produces 'application/json'
      description 'Get detailed information for a movie or TV show by TMDB ID. Fetches data from TMDB API and enriches with user-specific data.'
      security [ bearerAuth: [] ]

      parameter name: :tmdb_id, in: :path, type: :string, required: true,
        description: 'TMDB (The Movie Database) ID',
        example: '603'

      parameter name: :is_movie, in: :query, type: :boolean, required: false,
        description: 'Whether the ID refers to a movie (true) or TV show (false). Defaults to true if not specified or not "false".',
        example: true

      response '200', 'Movie details retrieved successfully' do
        schema type: :object,
          properties: {
            movie: {
              type: :object,
              properties: {
                id: {
                  type: :integer,
                  nullable: true,
                  description: 'Database ID (nil if not in database)',
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
                  description: 'User watch status (to_watch, watching, watched) if in_list is true, otherwise TMDB release status (e.g., "Released", "Post Production")',
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
                  description: 'Popularity score from TMDB',
                  example: 85.5
                },
                adult: {
                  type: :boolean,
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
                  description: 'Whether the content has video (typically false for movies)',
                  example: false
                },
                vote_average: {
                  type: :number,
                  description: 'Average vote rating from TMDB',
                  example: 7.623
                },
                vote_count: {
                  type: :integer,
                  description: 'Number of votes on TMDB',
                  example: 18910
                }
              }
            }
          },
          required: [ 'movie' ],
          example: {
            movie: {
              id: nil,
              tmdb_id: 603,
              title: 'The Matrix',
              release_date: '1999-03-31',
              poster_path: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
              is_movie: true,
              in_list: false,
              user_movie_id: nil,
              overview: 'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.',
              popularity: 85.5,
              adult: false,
              backdrop_path: '/fNG7i7RqMErkcqhohV2a6cV1Ehy.jpg',
              genre_ids: [ 28, 878 ],
              original_language: 'en',
              original_title: 'The Matrix',
              video: false,
              vote_average: 8.7,
              vote_count: 25000
            }
          }

        let(:Authorization) do
          user = create_test_user(email: 'details@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:tmdb_id) { '603' }
        let(:is_movie) { true }

        run_test! do
          data = JSON.parse(response.body)
          expect(data['movie']).to be_present
          expect(data['movie']['tmdb_id']).to eq(603)
          expect(data['movie']['title']).to be_present
          expect(data['movie']['is_movie']).to eq(true)
        end
      end

      # Note: 400 response for missing tmdb_id is not testable via rswag path parameters
      # because if the path parameter is missing, Rails routing fails before reaching the controller

      response '401', 'Unauthorized' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'You need to sign in or sign up before continuing.'
            }
          },
          required: [ 'error' ]

        let(:Authorization) { nil }
        let(:tmdb_id) { '603' }
        let(:is_movie) { true }

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to be_present
        end
      end

      response '422', 'Unprocessable entity - MovieService error' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'API request failed'
            }
          },
          required: [ 'error' ]

        let(:Authorization) do
          user = create_test_user(email: 'details3@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:tmdb_id) { '999999' }
        let(:is_movie) { true }

        # Mock MovieService to return an error
        before do
          allow(MovieService).to receive(:movie_details).and_return({ error: 'API request failed', status: 404 })
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(data['error']).to be_present
        end
      end

      response '500', 'Internal server error' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Failed to fetch movie details'
            },
            details: {
              type: :string,
              description: 'Error details',
              example: 'Connection timeout'
            }
          },
          required: [ 'error' ]

        let(:Authorization) do
          user = create_test_user(email: 'details4@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:tmdb_id) { '603' }
        let(:is_movie) { true }

        # Mock MovieService to raise an error
        before do
          allow(MovieService).to receive(:movie_details).and_raise(StandardError.new('Connection timeout'))
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:internal_server_error)
          expect(data['error']).to eq('Failed to fetch movie details')
          expect(data['details']).to be_present
        end
      end
    end
  end
end
