# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, options = {})
    if resource.persisted?
      render json: {
        status: 200, message: "Signed up successfully", data: resource
      }, status: :ok
    else
      render json: {
        status: 400, message: "User could not be created.", errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
