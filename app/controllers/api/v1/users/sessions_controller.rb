# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        include Api::V1::ApiResponder

        # POST /resource/sign_in
        def create
          self.resource = warden.authenticate!(auth_options)
          set_flash_message!(:notice, :signed_in)
          sign_in(resource_name, resource)
          yield resource if block_given?
          respond_with resource, location: after_sign_in_path_for(resource)
          # rescue Warden::NotAuthenticated
          #   # Catch authentication failure and handle it explicitly
          #   # This prevents Devise's failure app from being used
          #   respond_to_on_failure
          # rescue => e
          #   # Catch any other exceptions and handle them
          #   Rails.logger.error "Sign in error: #{e.class} - #{e.message}"
          #   respond_to_on_failure
        end

        private

        def respond_with(resource, options = {})
          # Devise-JWT automatically adds the JWT token to the response headers
          # The token will be in response.headers['Authorization'] after this method completes
          # We just need to return the user data and success message
          # NOTE: During sign-in, there is NO Authorization header in the request!
          # Ignore the location option for API responses
          render_success(
            data: {
              id: resource.id,
              email: resource.email,
              jti: resource.jti
            },
            message: "User signed in successfully"
          )
        end

        def respond_to_on_destroy
          # This method is ONLY called when DELETE /api/v1/users/sign_out is called
          # NOT during sign-in! The client should include the JWT token in the Authorization header
          # Devise-JWT handles the actual token revocation internally
          render_success(message: "Signed out successfully")
        end

        def respond_to_on_failure
          # This method is called when authentication fails (sign_in fails)
          # We need to explicitly handle this to prevent Devise from redirecting or triggering sign_out
          render_error(
            message: "Invalid email or password",
            status: :unauthorized
          )
        end

        protected

        # Override sign_in_params to ensure proper parameter handling for API
        def sign_in_params
          params.fetch(:user, {}).permit(:email, :password)
        end
      end
    end
  end
end
