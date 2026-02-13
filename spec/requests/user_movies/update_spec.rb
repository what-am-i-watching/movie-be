# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UserMovies::Update', type: :request do
  path '/user_movies/{id}' do
    patch 'Update a user movie' do
      tags 'User Movies'
      consumes 'application/json'
      produces 'application/json'
      description 'Update an existing user movie entry. Updates the watch status, rating, notes, or progress notes for a movie or TV show in the user\'s list. Returns enriched movie data with user-specific fields.'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
        description: 'User movie association ID',
        example: 1

      parameter name: :user_movie, in: :body, schema: {
        type: :object,
        properties: {
          status: {
            type: :string,
            enum: [ 'to_watch', 'watching', 'watched' ],
            nullable: true,
            description: 'Watch status',
            example: 'watching'
          },
          rating: {
            type: :integer,
            nullable: true,
            minimum: 0,
            maximum: 5,
            description: 'User rating from 0 to 5 (optional). Must be 0-5 when provided.',
            example: 4
          },
          notes: {
            type: :string,
            nullable: true,
            description: 'User notes about the movie/show',
            example: 'Really enjoying this!'
          }
        }
      }

      response '200', 'User movie updated successfully' do
        schema type: :object,
          properties: {
            user_movie: {
              type: :object,
              properties: {
                id: {
                  type: :integer,
                  description: 'Database ID',
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
                  description: 'Whether this movie/show is in the user\'s list (always true for this endpoint)',
                  example: true
                },
                user_movie_id: {
                  type: :integer,
                  description: 'User movie association ID',
                  example: 5
                },
                status: {
                  type: :string,
                  nullable: true,
                  enum: [ 'to_watch', 'watching', 'watched' ],
                  description: 'User watch status',
                  example: 'watching'
                },
                rating: {
                  type: :integer,
                  nullable: true,
                  description: 'User rating',
                  example: 4
                },
                notes: {
                  type: :string,
                  nullable: true,
                  description: 'User notes',
                  example: 'Really enjoying this!'
                },
                overview: {
                  type: :string,
                  nullable: true,
                  description: 'Plot overview/synopsis',
                  example: 'A computer hacker learns from mysterious rebels about the true nature of his reality.'
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
                  description: 'Original language code',
                  example: 'en'
                },
                original_title: {
                  type: :string,
                  nullable: true,
                  description: 'Original title',
                  example: 'The Matrix'
                },
                video: {
                  type: :boolean,
                  nullable: true,
                  description: 'Whether the content has video',
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
            }
          },
          required: [ 'user_movie' ],
          example: {
            user_movie: {
              id: 1,
              tmdb_id: 603,
              title: 'The Matrix',
              release_date: '1999-03-31',
              poster_path: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
              is_movie: true,
              in_list: true,
              user_movie_id: 5,
              status: 'watching',
              rating: 4,
              notes: 'Really enjoying this!',
              overview: 'A computer hacker learns from mysterious rebels about the true nature of his reality.',
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

        let!(:user) { create_test_user(email: 'um-update@example.com') }
        let!(:movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix', release_date: '1999-03-31') }
        let!(:existing_user_movie) { create_test_user_movie(user: user, movie: movie, status: 'to_watch', rating: nil, notes: nil) }
        let(:Authorization) do
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { existing_user_movie.id }
        let(:user_movie) do
          {
            status: 'watched',
            rating: 4,
            notes: 'Best show ever!!'
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['user_movie']).to be_present
          expect(data['user_movie']['id']).to eq(movie.id)
          expect(data['user_movie']['tmdb_id']).to eq(603)
          expect(data['user_movie']['title']).to eq('The Matrix')
          expect(data['user_movie']['in_list']).to eq(true)
          expect(data['user_movie']['status']).to eq('watched')
          expect(data['user_movie']['rating']).to eq(4)
          expect(data['user_movie']['notes']).to eq('Best show ever!!')
        end
      end

      response '404', 'User movie not found' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'User movie not found'
            }
          },
          required: [ 'error' ]

        let(:Authorization) do
          user = create_test_user(email: 'um-update2@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { 99999 }
        let(:user_movie) do
          {
            status: 'watching',
            rating: 4
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:not_found)
          expect(data['error']).to eq('User movie not found')
        end
      end

      response '404', 'User movie not found (authorization check)' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'User movie not found'
            }
          },
          required: [ 'error' ],
          description: 'Returns 404 when user tries to update another user\'s movie (authorization check)'

        let!(:user1) { create_test_user(email: 'um-update-user1@example.com') }
        let!(:user2) { create_test_user(email: 'um-update-user2@example.com') }
        let!(:movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix') }
        let!(:user1_movie) { create_test_user_movie(user: user1, movie: movie) }
        let(:Authorization) do
          post '/users/sign_in', params: { user: { email: user2.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { user1_movie.id }
        let(:user_movie) do
          {
            status: 'watching',
            rating: 4
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:not_found)
          expect(data['error']).to eq('User movie not found')
          # Verify the user_movie still exists and wasn't modified
          user1_movie.reload
          expect(user1_movie.status).not_to eq('watching')
        end
      end

      response '422', 'Validation errors (invalid status)' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              description: 'Array of validation error messages'
            }
          },
          required: [ 'errors' ],
          example: {
            errors: [
              "Status is not included in the list"
            ]
          }

        let!(:user) { create_test_user(email: 'um-update3@example.com') }
        let!(:movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix') }
        let!(:existing_user_movie) { create_test_user_movie(user: user, movie: movie) }
        let(:Authorization) do
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { existing_user_movie.id }
        let(:user_movie) do
          {
            status: 'invalid_status'
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(data['errors']).to be_present
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].length).to be > 0
        end
      end

      response '422', 'Validation errors (invalid rating)' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              description: 'Array of validation error messages'
            }
          },
          required: [ 'errors' ],
          example: {
            errors: [
              "Rating must be less than or equal to 5"
            ]
          }

        let!(:user) { create_test_user(email: 'um-update-rating@example.com') }
        let!(:movie) { create_test_movie(tmdb_id: 60301, title: 'Rating Update Movie', release_date: '2020-01-01') }
        let!(:existing_user_movie) { create_test_user_movie(user: user, movie: movie, status: 'to_watch') }
        let(:Authorization) do
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { existing_user_movie.id }
        let(:user_movie) do
          {
            rating: 6
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(data['errors']).to be_present
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].any? { |e| e.include?('Rating') }).to be true
        end
      end

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
        let(:id) { 1 }
        let(:user_movie) do
          {
            status: 'watching',
            rating: 4
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to be_present
        end
      end
    end
  end
end
