# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UserMovies::Destroy', type: :request do
  path '/user_movies/{id}' do
    delete 'Delete a user movie' do
      tags 'User Movies'
      produces 'application/json'
      description 'Remove a movie or TV show from the user\'s list by deleting the user_movie association.'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
        description: 'User movie association ID',
        example: 1

      response '204', 'User movie deleted successfully' do
        let!(:user) { create_test_user(email: 'um-destroy@example.com') }
        let!(:movie) { create_test_movie(tmdb_id: 603, title: 'The Matrix') }
        let!(:user_movie) { create_test_user_movie(user: user, movie: movie) }
        let(:Authorization) do
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end
        let(:id) { user_movie.id }

        run_test! do
          expect(response).to have_http_status(:no_content)
          expect(response.body).to be_blank
          expect(UserMovie.find_by(id: user_movie.id)).to be_nil
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
          user = create_test_user(email: 'um-destroy2@example.com')
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
    end
  end
end
