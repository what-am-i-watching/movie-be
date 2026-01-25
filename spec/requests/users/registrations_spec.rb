# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users::Registrations', type: :request do
  path '/users' do
    post 'Create a new user account' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Register a new user account. Returns user data and JWT token in Authorization header.'
      security [] # No authentication required for registration

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
                description: 'User password (minimum length may apply)',
                minLength: 6
              }
            },
            required: [ 'email', 'password' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'User created successfully' do
        schema type: :object,
          properties: {
            status: {
              type: :integer,
              example: 200
            },
            message: {
              type: :string,
              example: 'Signed up successfully'
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

        # Provide empty Authorization to satisfy rswag's security header resolution
        let(:Authorization) { nil }
        let(:user) do
          {
            user: {
              email: 'newuser@example.com',
              password: 'password123'
            }
          }
        end

        run_test! do
          data = JSON.parse(response.body)
          expect(data['status']).to eq(200)
          expect(data['message']).to eq('Signed up successfully')
          expect(data['data']).to be_present
          expect(data['data']['email']).to eq('newuser@example.com')
        end
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            status: {
              type: :integer,
              example: 400
            },
            message: {
              type: :string,
              example: 'User could not be created.'
            },
            errors: {
              type: :array,
              items: { type: :string },
              example: [ 'Email has already been taken', 'Password is too short (minimum is 6 characters)' ]
            }
          },
          required: [ 'status', 'message', 'errors' ]

        context 'when email is already taken' do
          let(:Authorization) { nil }
          let!(:existing_user) { create_test_user(email: 'existing@example.com') }
          let(:user) do
            {
              user: {
                email: 'existing@example.com',
                password: 'password123'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(data['status']).to eq(400)
            expect(data['errors']).to be_present
          end
        end

        context 'when password is too short' do
          let(:Authorization) { nil }
          let(:user) do
            {
              user: {
                email: 'shortpass@example.com',
                password: '123'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(data['status']).to eq(400)
            expect(data['errors']).to be_present
          end
        end

        context 'when email is invalid' do
          let(:Authorization) { nil }
          let(:user) do
            {
              user: {
                email: 'invalid-email',
                password: 'password123'
              }
            }
          end

          run_test! do
            data = JSON.parse(response.body)
            expect(data['status']).to eq(400)
            expect(data['errors']).to be_present
          end
        end
      end
    end
  end
end
