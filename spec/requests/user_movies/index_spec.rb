# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UserMovies::Index', type: :request do
  path '/user_movies' do
    get 'List user movies' do
      tags 'User Movies'
      produces 'application/json'
      description 'Get the current user\'s movie/TV show list. Returns enriched movie data with user-specific fields (status, rating, notes). All items have in_list true.'
      security [ bearerAuth: [] ]

      response '200', 'User movies list' do
        schema type: :object,
          properties: {
            user_movies: {
              type: :array,
              items: {
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
            }
          },
          required: [ 'user_movies' ],
          example: {
            user_movies: [
              {
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
            ]
          }

        let(:Authorization) do
          user = create_test_user(email: 'um-index@example.com')
          create_test_user_movie(user: user, movie: create_test_movie(tmdb_id: 603, title: 'The Matrix'))
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['user_movies']).to be_an(Array)
          expect(data['user_movies'].length).to be >= 1
          movie = data['user_movies'].first
          expect(movie['tmdb_id']).to eq(603)
          expect(movie['title']).to eq('The Matrix')
          expect(movie['in_list']).to eq(true)
          expect(movie).to have_key('user_movie_id')
          expect(movie).to have_key('status')
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

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to be_present
        end
      end
    end
  end
end
