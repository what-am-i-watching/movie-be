# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health', type: :request do
  describe 'GET /health' do
    it 'returns 200 OK' do
      get '/health', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON with status, database_connected, and rails_env' do
      get '/health', headers: { 'Accept' => 'application/json' }

      json = JSON.parse(response.body)
      expect(json).to have_key('status')
      expect(json['status']).to eq('online')
      expect(json).to have_key('database_connected')
      expect(json['database_connected']).to eq(true)
      expect(json).to have_key('existing_tables')
      expect(json['existing_tables']).to be_an(Array)
      expect(json).to have_key('solid_cache_exists')
      expect(json).to have_key('rails_env')
      expect(json['rails_env']).to eq(Rails.env)
    end

    it 'does not require authentication' do
      get '/health', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /up' do
    it 'returns 200 OK when app is healthy' do
      get '/up'

      expect(response).to have_http_status(:ok)
    end

    it 'returns a success response body' do
      get '/up'

      expect(response.body).to be_present
    end
  end
end
