# frozen_string_literal: true

module Api
  module V1
    module Users
      # Base controller for user-related endpoints
      # Inherits from Api::V1::BaseController which already includes ApiResponder
      # Use this for any user-specific controllers that don't need Devise functionality
      class BaseController < Api::V1::BaseController
        # Add any user-specific shared functionality here
        # For example: user authentication helpers, user-specific error handling, etc.
      end
    end
  end
end
