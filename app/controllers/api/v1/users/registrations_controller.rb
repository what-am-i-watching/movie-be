# frozen_string_literal: true

module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        include Api::V1::ApiResponder

        before_action :configure_sign_up_params, only: [ :create ]
        before_action :configure_account_update_params, only: [ :update ]

        private

        def respond_with(resource, options = {})
          if resource.persisted?
            render_success(
              data: resource,
              message: "Signed up successfully"
            )
          else
            render_error(
              message: "User could not be created.",
              errors: resource.errors.full_messages
            )
          end
        end

        # GET /resource/sign_up
        # def new
        #   super
        # end

        # POST /resource
        # def create
        #   super
        # end

        # GET /resource/edit
        # def edit
        #   super
        # end

        # PUT /resource
        # def update
        #   super
        # end

        # DELETE /resource
        # def destroy
        #   super
        # end

        # GET /resource/cancel
        # Forces the session data which is usually expired after sign
        # in to be expired now. This is useful if the user wants to
        # cancel oauth signing in/up in the middle of the process,
        # removing all OAuth session data.
        # def cancel
        #   super
        # end

        protected

        # Permit the parameters for user registration
        def configure_sign_up_params
          devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :password, :password_confirmation ])
        end

        # Override sign_up_params to ensure proper parameter handling for API
        def sign_up_params
          params.fetch(:user, {}).permit(:email, :password, :password_confirmation)
        end

        # Permit the parameters for account updates
        def configure_account_update_params
          devise_parameter_sanitizer.permit(:account_update, keys: [ :email, :password, :password_confirmation, :current_password ])
        end

        # The path used after sign up.
        # def after_sign_up_path_for(resource)
        #   super(resource)
        # end

        # The path used after sign up for inactive accounts.
        # def after_inactive_sign_up_path_for(resource)
        #   super(resource)
        # end
      end
    end
  end
end
