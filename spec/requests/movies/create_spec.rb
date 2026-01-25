# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Movies::Create', type: :request do
  path '/movies' do
    post 'Create a new movie or TV show' do
      tags 'Movies'
      consumes 'application/json'
      produces 'application/json'
      description 'Create a new movie or TV show in the database. If a movie with the same tmdb_id already exists, returns the existing movie with status 200. Otherwise, creates a new movie and returns it with status 201.'
      security [ bearerAuth: [] ]

      parameter name: :movie, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string,
            description: 'Movie or TV show title',
            example: 'The Matrix'
          },
          tmdb_id: {
            type: :integer,
            description: 'TMDB (The Movie Database) ID',
            example: 603
          },
          release_date: {
            type: :string,
            format: :date,
            description: 'Release date (movies) or first air date (TV shows) in YYYY-MM-DD format',
            example: '1999-03-31'
          },
          poster_url: {
            type: :string,
            nullable: true,
            description: 'Poster image URL',
            example: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg'
          },
          is_movie: {
            type: :boolean,
            description: 'True if movie, false if TV show',
            example: true
          }
        },
        required: [ 'title', 'tmdb_id', 'release_date', 'is_movie' ]
      }

      response '200', 'Movie already exists' do
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
              id: 1,
              tmdb_id: 603,
              title: 'The Matrix',
              release_date: '1999-03-31',
              poster_path: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
              is_movie: true,
              in_list: false,
              user_movie_id: nil,
              status: nil,
              tmdb_status: 'Released',
              rating: nil,
              notes: nil,
              progress_notes: nil,
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
          user = create_test_user(email: 'create1@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let!(:existing_movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix', release_date: '1999-03-31', is_movie: true) }
        let(:movie) do
          {
            title: 'The Matrix',
            tmdb_id: 603,
            release_date: '1999-03-31',
            poster_url: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
            is_movie: true
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['movie']).to be_present
          expect(data['movie']['id']).to eq(existing_movie.id)
          expect(data['movie']['tmdb_id']).to eq(603)
          expect(data['movie']['title']).to eq('The Matrix')
        end
      end

      response '201', 'Movie created successfully' do
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
              id: 1,
              tmdb_id: 603,
              title: 'The Matrix',
              release_date: '1999-03-31',
              poster_path: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
              is_movie: true,
              in_list: false,
              user_movie_id: nil,
              status: nil,
              tmdb_status: 'Released',
              rating: nil,
              notes: nil,
              progress_notes: nil,
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
          user = create_test_user(email: 'create2@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:movie) do
          {
            title: 'Inception',
            tmdb_id: 27205,
            release_date: '2010-07-16',
            poster_url: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
            is_movie: true
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['movie']).to be_present
          expect(data['movie']['tmdb_id']).to eq(27205)
          expect(data['movie']['title']).to eq('Inception')
          expect(data['movie']['is_movie']).to eq(true)
          expect(Movie.find_by(tmdb_id: 27205)).to be_present
        end
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              description: 'Array of validation error messages'
            }
          },
          example: {
            errors: [
              "Tmdb can't be blank",
              "Title can't be blank",
              "Release year can't be blank"
            ]
          }

        let(:Authorization) do
          user = create_test_user(email: 'create3@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:movie) do
          {
            # Missing required fields: title, tmdb_id, release_year, is_movie
            poster_url: 'https://example.com/poster.jpg'
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(data['errors']).to be_present
          expect(data['errors']).to be_an(Array)
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
        let(:movie) do
          {
            title: 'The Matrix',
            tmdb_id: 603,
            release_date: '1999-03-31',
            is_movie: true
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
