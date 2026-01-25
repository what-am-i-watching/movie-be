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
                id: { type: :integer },
                email: { type: :string, format: :email },
                created_at: { type: :string, format: :date_time },
                updated_at: { type: :string, format: :date_time },
                jti: { type: :string }
              }
            }
          },
          required: [ 'status', 'message', 'data' ]

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

  describe 'GET /me' do
    let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/me', headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns JSON error message' do
        get '/me', headers: { 'Accept' => 'application/json' }

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to be_present
        expect(json_response['data']).to be_nil
      end
    end

    context 'when token is invalid' do
      it 'returns unauthorized status' do
        headers = {
          'Authorization' => 'Bearer invalid_token',
          'Accept' => 'application/json'
        }
        get '/me', headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when token is expired' do
      it 'returns unauthorized status' do
        # Create an expired token
        secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') { Rails.application.secret_key_base }
        payload = {
          sub: user.id.to_s,
          scp: 'user',
          jti: user.jti,
          exp: 1.day.ago.to_i # Expired token
        }
        expired_token = JWT.encode(payload, secret, 'HS256')
        headers = {
          'Authorization' => "Bearer #{expired_token}",
          'Accept' => 'application/json'
        }

        get '/me', headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      it 'returns the current user information' do
        # First, sign in to get a real JWT token
        post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
        token = response.headers['Authorization']

        # Use the token from the sign-in response
        headers = {
          'Authorization' => token,
          'Accept' => 'application/json'
        }
        get '/me', headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_present
        expect(json_response['data']['id']).to eq(user.id.to_s)
        expect(json_response['data']['attributes']['email']).to eq(user.email)
      end

      it 'returns user data in JSONAPI format' do
        # First, sign in to get a real JWT token
        post '/users/sign_in', params: { user: { email: user.email, password: 'password123' } }
        token = response.headers['Authorization']

        # Use the token from the sign-in response
        headers = {
          'Authorization' => token,
          'Accept' => 'application/json'
        }
        get '/me', headers: headers

        json_response = JSON.parse(response.body)
        expect(json_response['data']).to have_key('id')
        expect(json_response['data']).to have_key('type')
        expect(json_response['data']).to have_key('attributes')
        expect(json_response['data']['attributes']).to have_key('email')
        expect(json_response['data']['attributes']).to have_key('created_at')
      end
    end
  end
end
