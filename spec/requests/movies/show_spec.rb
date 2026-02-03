# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Movies::Show', type: :request do
  path '/movies/{id}' do
    get 'Get movie by database ID' do
      tags 'Movies'
      produces 'application/json'
      description 'Get a movie or TV show by its database ID. Returns enriched data with user-specific information (in_list, status, rating, etc.).'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
        description: 'Database ID of the movie',
        example: 1

      response '200', 'Movie retrieved successfully' do
        schema type: :object,
          properties: {
            movie: {
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
          user = create_test_user(email: 'show@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let!(:movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix') }
        let(:id) { movie.id }

        run_test! do
          data = JSON.parse(response.body)
          expect(data['movie']).to be_present
          expect(data['movie']['id']).to eq(movie.id)
          expect(data['movie']['tmdb_id']).to eq(603)
          expect(data['movie']['title']).to eq('The Matrix')
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

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to be_present
        end
      end

      response '404', 'Movie not found' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Movie not found'
            }
          },
          required: [ 'error' ]

        let(:Authorization) do
          user = create_test_user(email: 'show2@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { 99999 }

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:not_found)
          expect(data['error']).to be_present
        end
      end
    end
  end
end
