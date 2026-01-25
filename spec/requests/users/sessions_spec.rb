# frozen_string_literal: true

require 'swagger_helper'
require 'jwt'

RSpec.describe 'Users::Sessions', type: :request do
  path '/users/sign_in' do
    post 'Sign in' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Authenticate user with email and password. Returns user data and JWT in Authorization header.'
      security [] # No authentication required for sign in

      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: {
                type: :string,
                format: :email,
                example: 'user@example.com',
                description: 'User email address'
              },
              password: {
                type: :string,
                format: :password,
                example: 'password123',
                description: 'User password'
              }
            },
            required: [ 'email', 'password' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'User signed in successfully' do
        schema type: :object,
          properties: {
            status: {
              type: :integer,
              example: 200
            },
            message: {
              type: :string,
              example: 'User signed in successfully'
            },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                email: { type: :string, format: :email, example: 'user@example.com' },
                created_at: { type: :string, format: :date_time, example: '2024-01-01T00:00:00.000Z' },
                updated_at: { type: :string, format: :date_time, example: '2024-01-01T00:00:00.000Z' },
                jti: { type: :string, example: 'abc123def456' }
              }
            }
          },
          required: [ 'status', 'message', 'data' ],
          example: {
            status: 200,
            message: 'User signed in successfully',
            data: {
              id: 1,
              email: 'user@example.com',
              created_at: '2024-01-01T00:00:00.000Z',
              updated_at: '2024-01-01T00:00:00.000Z',
              jti: 'abc123def456'
            }
          }

        let(:Authorization) { nil }
        let!(:sign_in_user) { create_test_user(email: 'signin@example.com') }
        let(:user) do
          {
            user: {
              email: 'signin@example.com',
              password: 'password123'
            }
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['status']).to eq(200)
          expect(data['message']).to eq('User signed in successfully')
          expect(data['data']).to be_present
          expect(data['data']['email']).to eq('signin@example.com')
          expect(response.headers['Authorization']).to be_present
          expect(response.headers['Authorization']).to start_with('Bearer ')
        end
      end

      response '401', 'Invalid credentials' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Invalid Email or password.',
              description: 'Error message (e.g. invalid credentials or unauthenticated)'
            },
            message: {
              type: :string,
              description: 'Additional i18n message when present'
            }
          },
          required: [ 'error' ]

        context 'when password is wrong' do
          let(:Authorization) { nil }
          let!(:sign_in_user) { create_test_user(email: 'wrongpass@example.com') }
          let(:user) do
            {
              user: {
                email: 'wrongpass@example.com',
                password: 'wrongpassword'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unauthorized)
            expect(data['error']).to be_present
          end
        end

        context 'when email does not exist' do
          let(:Authorization) { nil }
          let(:user) do
            {
              user: {
                email: 'nonexistent@example.com',
                password: 'password123'
              }
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

  path '/me' do
    get 'Get current user' do
      tags 'Authentication'
      produces 'application/json'
      description 'Get the currently authenticated user information. Requires valid JWT token in Authorization header.'
      security [ bearerAuth: [] ]

      response '200', 'User information retrieved successfully' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string, example: '1' },
                type: { type: :string, example: 'user' },
                attributes: {
                  type: :object,
                  properties: {
                    email: { type: :string, format: :email, example: 'user@example.com' },
                    created_at: { type: :string, format: :date_time, example: '2024-01-01T00:00:00.000Z' }
                  }
                }
              }
            }
          },
          required: [ 'data' ],
          example: {
            data: {
              id: '1',
              type: 'user',
              attributes: {
                email: 'user@example.com',
                created_at: '2024-01-01T00:00:00.000Z'
              }
            }
          }

        let(:Authorization) do
          # Create a user and sign in to get a valid token
          user = create_test_user(email: 'me@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['data']).to be_present
          expect(data['data']['id']).to be_present
          expect(data['data']['type']).to eq('user')
          expect(data['data']['attributes']).to be_present
          expect(data['data']['attributes']['email']).to eq('me@example.com')
        end
      end

      response '401', 'Unauthorized' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'You need to sign in or sign up before continuing.',
              description: 'Error message when authentication fails'
            }
          },
          required: [ 'error' ]

        context 'when no token is provided' do
          let(:Authorization) { nil }

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unauthorized)
            expect(data['error']).to be_present
          end
        end

        context 'when token is invalid' do
          let(:Authorization) { 'Bearer invalid_token' }

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unauthorized)
            expect(data['error']).to be_present
          end
        end

        context 'when token is expired' do
          let(:Authorization) do
            user = create_test_user(email: 'expired@example.com')
            secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') { Rails.application.secret_key_base }
            payload = {
              sub: user.id.to_s,
              scp: 'user',
              jti: user.jti,
              exp: 1.day.ago.to_i
            }
            "Bearer #{JWT.encode(payload, secret, 'HS256')}"
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

  path '/users/sign_out' do
    delete 'Sign out' do
      tags 'Authentication'
      produces 'application/json'
      description 'Sign out the current user. Invalidates the JWT token. Works even if token is expired.'
      security [ bearerAuth: [] ]

      response '200', 'Signed out successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Signed out successfully' }
          },
          required: [ 'status', 'message' ]

        let(:Authorization) do
          user = create_test_user(email: 'signout@example.com')
          post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
          response.headers['Authorization']
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['status']).to eq(200)
          expect(data['message']).to eq('Signed out successfully')
        end
      end

      response '401', 'No token provided' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 401 },
            message: { type: :string, example: 'No token provided' }
          },
          required: [ 'status', 'message' ]

        let(:Authorization) { nil }

        run_test! do
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['status']).to eq(401)
          expect(data['message']).to eq('No token provided')
        end
      end
    end
  end
end
