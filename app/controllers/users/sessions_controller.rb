# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :authenticate_user!, only: [ :show ]

  respond_to :json

  def show
    if current_user
      render json: UserSerializer.new(current_user), status: :ok
    else
      render json: {
        error: "You need to sign in or sign up before continuing."
      }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, options = {})
    render json: {
      status: 200,
      message: "User signed in successfully",
      data: current_user
    },
      status: :ok
  end

  def respond_to_on_destroy
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.blank?
      render json: {
        status: 401,
        message: "No token provided"
      }, status: :unauthorized
      return
    end

    begin
      jwt_payload = JWT.decode(
        token,
        ENV["DEVISE_JWT_SECRET_KEY"],
        true,
        { verify_expiration: false }
      ).first

      current_user = User.find_by(id: jwt_payload["sub"])
      if current_user
        render json: {
          status: 200,
          message: "Signed out successfully"
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "User has no active session"
        }, status: :unauthorized
      end
    rescue JWT::ExpiredSignature, JWT::DecodeError => e
      render json: {
        status: 200,
        message: "Signed out successfully"
      }, status: :ok
    end
  end
end
