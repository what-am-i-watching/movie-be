# frozen_string_literal: true

require 'jwt'

module AuthenticationHelper
  def auth_headers(user)
    # Generate a JWT token for the user using the same method devise-jwt uses
    # This creates a token that devise-jwt will recognize
    secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') { Rails.application.secret_key_base }

    # Get the JWT payload from the user (devise-jwt adds this method)
    payload = user.jwt_payload.merge(
      exp: 1.day.from_now.to_i,
      iat: Time.now.to_i
    )

    token = JWT.encode(payload, secret, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end

  def sign_in_user(user)
    # Helper method to sign in a user and return auth headers
    auth_headers(user)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
