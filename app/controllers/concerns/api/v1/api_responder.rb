# frozen_string_literal: true

module Api
  module V1
    module ApiResponder
      extend ActiveSupport::Concern

      included do
        respond_to :json
      end

      private

      def render_success(data: nil, message: nil, status: :ok)
        status_code = status.is_a?(Symbol) ? Rack::Utils.status_code(status) : status
        response = { status: status_code }
        response[:message] = message if message
        response[:data] = data if data
        render json: response, status: status
      end

      def render_error(message:, errors: nil, status: :unprocessable_content)
        status_code = status.is_a?(Symbol) ? Rack::Utils.status_code(status) : status
        response = {
          status: status_code,
          message: message
        }
        response[:errors] = errors if errors
        render json: response, status: status
      end

      def render_not_found(message: "Resource not found")
        render json: {
          status: 404,
          message: message
        }, status: :not_found
      end

      def render_unauthorized(message: "Unauthorized")
        render json: {
          status: 401,
          message: message
        }, status: :unauthorized
      end
    end
  end
end
