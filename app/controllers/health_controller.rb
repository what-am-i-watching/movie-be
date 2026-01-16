class HealthController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def check
    # This will tell us exactly which tables exist in the production DB
    tables = ActiveRecord::Base.connection.tables

    render json: {
      status: "online",
      database_connected: ActiveRecord::Base.connection.active?,
      existing_tables: tables,
      solid_cache_exists: tables.include?("solid_cache_entries"),
      rails_env: Rails.env
    }
  rescue => e
    render json: { error: e.message, backtrace: e.backtrace.first(5) }, status: 500
  end
end
