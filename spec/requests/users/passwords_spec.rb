# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users::Passwords', type: :request do
  path '/users/password' do
    post 'Request password reset' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Request password reset instructions. Sends an email with reset link to the user.'
      security [] # No authentication required

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
              }
            },
            required: [ 'email' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'Password reset instructions sent' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Password reset instructions sent to your email'
            }
          },
          required: [ 'message' ]

        let(:Authorization) { nil }
        let!(:reset_user) { create_test_user(email: 'reset@example.com') }
        let(:user) do
          { user: { email: 'reset@example.com' } }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Password reset instructions sent to your email')
        end
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              example: [ 'Email not found' ]
            }
          },
          required: [ 'errors' ]

        context 'when email does not exist' do
          let(:Authorization) { nil }
          let(:user) do
            {
              user: {
                email: 'nonexistent@example.com'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(data['errors']).to be_present
          end
        end

        context 'when email is invalid' do
          let(:Authorization) { nil }
          let(:user) do
            {
              user: {
                email: 'invalid-email'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(data['errors']).to be_present
          end
        end
      end
    end

    patch 'Reset password with token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Reset password using the token from the reset email. Token is included in the reset link sent via email.'
      security [] # No authentication required

      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              reset_password_token: {
                type: :string,
                example: 'abc123def456',
                description: 'Token from password reset email link'
              },
              password: {
                type: :string,
                format: :password,
                example: 'newpassword123',
                description: 'New password',
                minLength: 6
              },
              password_confirmation: {
                type: :string,
                format: :password,
                example: 'newpassword123',
                description: 'Password confirmation (must match password)',
                minLength: 6
              }
            },
            required: [ 'reset_password_token', 'password', 'password_confirmation' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'Password successfully reset' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Password successfully reset'
            }
          },
          required: [ 'message' ]

        let(:Authorization) { nil }
        let!(:patch_user) { create_test_user(email: 'resetwithtoken@example.com') }
        let(:raw_token) do
          raw, enc = Devise.token_generator.generate(User, :reset_password_token)
          patch_user.update!(reset_password_token: enc, reset_password_sent_at: Time.current)
          raw
        end
        let(:user) do
          {
            user: {
              reset_password_token: raw_token,
              password: 'newpassword123',
              password_confirmation: 'newpassword123'
            }
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Password successfully reset')
        end
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              example: [ 'Reset password token is invalid', 'Password is too short (minimum is 6 characters)', "Password confirmation doesn't match Password" ]
            }
          },
          required: [ 'errors' ]

        context 'when token is invalid' do
          let(:Authorization) { nil }
          let(:user) do
            {
              user: {
                reset_password_token: 'invalid_token',
                password: 'newpassword123',
                password_confirmation: 'newpassword123'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(data['errors']).to be_present
          end
        end

        context 'when password is too short' do
          let(:Authorization) { nil }
          let!(:short_user) { create_test_user(email: 'shortpass@example.com') }
          let(:short_raw_token) do
            raw, enc = Devise.token_generator.generate(User, :reset_password_token)
            short_user.update!(reset_password_token: enc, reset_password_sent_at: Time.current)
            raw
          end
          let(:user) do
            {
              user: {
                reset_password_token: short_raw_token,
                password: '123',
                password_confirmation: '123'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(data['errors']).to be_present
          end
        end

        context 'when passwords do not match' do
          let(:Authorization) { nil }
          let!(:nomatch_user) { create_test_user(email: 'nomatch@example.com') }
          let(:nomatch_raw_token) do
            raw, enc = Devise.token_generator.generate(User, :reset_password_token)
            nomatch_user.update!(reset_password_token: enc, reset_password_sent_at: Time.current)
            raw
          end
          let(:user) do
            {
              user: {
                reset_password_token: nomatch_raw_token,
                password: 'newpassword123',
                password_confirmation: 'differentpassword'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(data['errors']).to be_present
          end
        end
      end
    end
  end
end
