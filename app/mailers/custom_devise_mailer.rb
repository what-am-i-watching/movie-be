class CustomDeviseMailer < Devise::Mailer
  def reset_password_instructions(record, token, opts = {})
    if Rails.env === "development"
      @reset_url = "http://localhost:5173/reset-password?token=#{token}"
    else
      @reset_url = "https://whatamiwatching.info/reset-password?token=#{token}"
    end
    super
  end
end
