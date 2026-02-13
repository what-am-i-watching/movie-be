# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UserMovies::Create', type: :request do
  path '/user_movies' do
    post 'Create or update a user movie' do
      tags 'User Movies'
      consumes 'application/json'
      produces 'application/json'
      description 'Add a movie or TV show to the user\'s list, or update an existing entry. If a user_movie with the same movie_id already exists for the user, it will be updated. Otherwise, a new user_movie is created. Returns enriched movie data with user-specific fields.'
      security [ bearerAuth: [] ]

      parameter name: :user_movie, in: :body, schema: {
        type: :object,
        properties: {
          movie_id: {
            type: :integer,
            description: 'Database ID of the movie',
            example: 1
          },
          status: {
            type: :string,
            enum: [ 'to_watch', 'watching', 'watched' ],
            nullable: true,
            description: 'Watch status',
            example: 'to_watch'
          },
          rating: {
            type: :integer,
            nullable: true,
            minimum: 0,
            maximum: 5,
            description: 'User rating from 0 to 5 (optional). Must be 0-5 when provided.',
            example: 5
          },
          notes: {
            type: :string,
            nullable: true,
            description: 'User notes about the movie/show',
            example: 'Great movie!'
          }
        },
        required: [ 'movie_id' ]
      }

      response '201', 'User movie created or updated successfully' do
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
                  example: 'to_watch'
                },
                rating: {
                  type: :integer,
                  nullable: true,
                  description: 'User rating',
                  example: 5
                },
                notes: {
                  type: :string,
                  nullable: true,
                  description: 'User notes',
                  example: 'Great movie!'
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
              status: 'watched',
              rating: 5,
              notes: 'One of my favorites!',
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

        let(:Authorization) do
          user = create_test_user(email: 'um-create@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let!(:movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix', release_date: '1999-03-31') }
        let(:user_movie) do
          {
            movie_id: movie.id,
            status: 'watched',
            rating: 5,
            notes: 'One of my favorites!'
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
          expect(data['user_movie']['rating']).to eq(5)
          expect(data['user_movie']['notes']).to eq('One of my favorites!')
        end
      end

      response '422', 'Validation errors (movie not found)' do
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
              "Movie must exist"
            ]
          }

        let(:Authorization) do
          user = create_test_user(email: 'um-create2@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:user_movie) do
          {
            # Invalid movie_id (movie doesn't exist)
            movie_id: 99999,
            status: 'to_watch',
            rating: 5
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

        let(:Authorization) do
          user = create_test_user(email: 'um-create-rating@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let!(:movie) { create_test_movie(tmdb_id: 99998, title: 'Rating Test Movie', release_date: '2020-01-01') }
        let(:user_movie) do
          {
            movie_id: movie.id,
            status: 'to_watch',
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
        let(:user_movie) do
          {
            movie_id: 1,
            status: 'to_watch'
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
