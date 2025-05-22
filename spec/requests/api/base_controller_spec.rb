require 'rails_helper'

RSpec.describe 'API Base Controller', type: :request do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user: user) }
  let(:headers) { { 'Authorization' => "Bearer #{api_token.token}" } }

  describe 'Authentication' do
    describe 'GET /api/users' do
      context 'with invalid credentials' do
        it 'returns 401 when no token provided' do
          get '/api/users'
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns 401 with invalid token format' do
          get '/api/users', headers: { 'Authorization' => 'invalid_format' }
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns 401 with invalid token' do
          get '/api/users', headers: { 'Authorization' => 'Bearer invalid_token' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe 'Authorization' do
    context 'with valid authentication' do
      context 'when user lacks permission' do
        it 'returns 403 forbidden' do
          get '/api/users', headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
