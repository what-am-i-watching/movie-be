# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Movies::Search', type: :request do
  path '/movies/search' do
    get 'Search movies and TV shows' do
      tags 'Movies'
      produces 'application/json'
      description 'Search for movies and TV shows by query string. Returns combined results sorted by popularity.'
      security [ bearerAuth: [] ]

      parameter name: :query, in: :query, type: :string, required: true,
        description: 'Search query string',
        example: 'The Matrix'

      response '200', 'Search results' do
        schema type: :object,
          properties: {
            movies: {
              type: :array,
              items: {
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
                    enum: [ 'to_watch', 'watching', 'watched' ],
                    description: 'Watch status (only present if in_list is true)',
                    example: 'to_watch'
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
            }
          },
          required: [ 'movies' ],
          example: {
            movies: [
              {
                id: 38,
                tmdb_id: 329865,
                title: 'Arrival',
                release_date: '2016-11-10',
                poster_path: '/iQBIXJprC8AN7Jwx7aOI0gPUqff.jpg',
                is_movie: true,
                in_list: true,
                user_movie_id: 36,
                status: 'watched',
                rating: 4,
                notes: nil,
                progress_notes: nil,
                overview: 'Taking place after alien crafts land around the world, an expert linguist is recruited by the military to determine whether they come in peace or are a threat.',
                popularity: 11.666,
                adult: false,
                backdrop_path: '/r8FD6CC3GgjWaGVkZh00AcedfpA.jpg',
                genre_ids: [ 18, 878, 9648 ],
                original_language: 'en',
                original_title: 'Arrival',
                video: false,
                vote_average: 7.623,
                vote_count: 18910
              },
              {
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
            ]
          }

        let(:Authorization) do
          user = create_test_user(email: 'search@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:query) { 'matrix' }

        run_test! do
          data = JSON.parse(response.body)
          expect(data['movies']).to be_an(Array)
          # If results exist, check structure of first item
          if data['movies'].any?
            movie = data['movies'].first
            expect(movie).to have_key('tmdb_id')
            expect(movie).to have_key('title')
            expect(movie).to have_key('is_movie')
            expect(movie).to have_key('in_list')
          end
        end
      end

      response '200', 'Empty results when query is missing' do
        schema type: :object,
          properties: {
            movies: {
              type: :array,
              items: { type: :object },
              example: []
            }
          },
          required: [ 'movies' ]

        let(:Authorization) do
          user = create_test_user(email: 'search2@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:query) { nil }

        run_test! do
          data = JSON.parse(response.body)
          expect(data['movies']).to eq([])
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
        let(:query) { 'matrix' }

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to be_present
        end
      end

      response '500', 'Internal server error' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Failed to fetch movies'
            },
            details: {
              type: :string,
              nullable: true,
              description: 'Error details (only present in development environment)',
              example: 'Connection timeout'
            }
          },
          required: [ 'error' ]

        let(:Authorization) do
          user = create_test_user(email: 'search3@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:query) { 'matrix' }

        # Mock MovieService to raise an error
        before do
          allow(MovieService).to receive(:search_movies).and_raise(StandardError.new('Connection timeout'))
          allow(ShowsService).to receive(:search_shows).and_raise(StandardError.new('Connection timeout'))
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:internal_server_error)
          expect(data['error']).to eq('Failed to fetch movies')
          # details is only present in development, nil in test/production
          expect(data.key?('details')).to be true
        end
      end
    end
  end
end
