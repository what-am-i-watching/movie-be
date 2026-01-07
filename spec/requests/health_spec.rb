require 'swagger_helper'

RSpec.describe 'Health API', type: :request do
  # Actually hits '/api/v1/health' because of configuration in swagger_helper.rb
  path '/health' do
    get 'Health check' do
      tags 'Health'
      produces 'application/json'

      response '200', 'ok' do
        schema type: :object,
              properties: {
                status: { type: :string }
              },
              required: [ 'status' ]

        run_test!
      end
    end
  end
end
