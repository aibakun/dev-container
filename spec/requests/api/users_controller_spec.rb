require 'rails_helper'

RSpec.describe 'API Users', type: :request do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user: user) }
  let(:headers) { { 'Authorization' => "Bearer #{api_token.token}" } }

  describe 'GET /api/users' do
    context 'with valid credentials and permissions' do
      before do
        create(:permission, user: user, controller: 'api/users', action: 'index')
      end

      it 'returns 200 and all users' do
        create_list(:user, 3)
        get '/api/users', headers: headers

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq(4)
      end
    end
  end
end
