RSpec.describe 'User Sessions API', type: :request do
  path '/users/sign_in' do   # relative to servers.url /api/v1
    post 'Sign in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'user signed in' do
        let(:user) { { email: 'test@example.com', password: 'password' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:user) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end
end
