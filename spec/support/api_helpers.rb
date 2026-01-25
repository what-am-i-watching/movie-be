# frozen_string_literal: true

module ApiHelpers
  # Helper method to get authentication headers for swagger documentation
  def auth_header
    {
      name: 'Authorization',
      in: :header,
      required: true,
      schema: {
        type: :string,
        example: 'Bearer eyJhbGciOiJIUzI1NiJ9...'
      },
      description: 'JWT token obtained from POST /users/sign_in'
    }
  end

  def create_test_user(email: 'test@example.com', password: 'password123')
    User.create!(
      email: email,
      password: password,
      password_confirmation: password
    )
  end

  def authenticated_headers(user)
    auth_headers(user)
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
