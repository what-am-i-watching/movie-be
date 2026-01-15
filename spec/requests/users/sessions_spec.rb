# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

RSpec.describe 'Users::Sessions', type: :request do
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
