# frozen_string_literal: true

RSpec.shared_examples 'returns unauthorized error' do
  it 'returns 401 status' do
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns error message' do
    json_response = JSON.parse(response.body)
    expect(json_response).to have_key('error')
  end
end

RSpec.shared_examples 'returns validation error' do |status_code = :unprocessable_entity|
  it "returns #{status_code} status" do
    expect(response).to have_http_status(status_code)
  end

  it 'returns error details' do
    json_response = JSON.parse(response.body)
    expect(json_response).to be_present
  end
end

RSpec.shared_examples 'returns success response' do |status_code = :ok|
  it "returns #{status_code} status" do
    expect(response).to have_http_status(status_code)
  end

  it 'returns JSON response' do
    expect(response.content_type).to include('application/json')
  end
end

RSpec.shared_examples 'returns not found error' do
  it 'returns 404 status' do
    expect(response).to have_http_status(:not_found)
  end
end

RSpec.shared_examples 'returns bad request error' do
  it 'returns 400 status' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns error message' do
    json_response = JSON.parse(response.body)
    expect(json_response).to have_key('error')
  end
end

RSpec.shared_examples 'requires authentication' do
  context 'when not authenticated' do
    before do
      # Make request without authentication
      # This will be overridden in each spec
    end

    it_behaves_like 'returns unauthorized error'
  end
end
