# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'What Am I Watching? API',
        version: '1.0.0',
        description: 'API for managing movies and TV shows watchlists',
        contact: {
          email: 'whatamiwatching.info@gmail.com'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://whatamiwatching.info',
          description: 'Production server'
        }
      ],
      tags: [
        { name: 'Authentication', description: 'User authentication endpoints' },
        { name: 'Movies', description: 'Movie and TV show endpoints' },
        { name: 'User Movies', description: 'User movie list management' },
        { name: 'Health', description: 'Health check endpoints' }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtained from POST /users/sign_in endpoint. Include the token in the Authorization header as: Bearer {token}'
          }
        },
        schemas: {}
      }
      # Security is applied per endpoint, not globally
      # Use security [bearerAuth: []] in endpoint specs that require authentication
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
