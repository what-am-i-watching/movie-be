# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def respond
    if request.format == :json || request.content_type&.include?("application/json") || api_request?
      json_error_response
    else
      super
    end
  end

  def json_error_response
    self.status = 401
    self.content_type = "application/json"
    self.response_body = {
      error: "You need to sign in or sign up before continuing.",
      message: i18n_message
    }.to_json
  end

  private

  def api_request?
    !request.format.html?
  end
end
