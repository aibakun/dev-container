require 'rails_helper'

RSpec.describe 'Api::InternalBase', type: :request do
  let(:user) { create(:user) }

  describe 'Authentication' do
    context 'when not logged in' do
      it 'returns unauthorized status' do
        get api_order_statistics_path
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'Authorization' do
    context 'when logged in without permission' do
      before do
        login(user, 'password')
      end

      it 'returns forbidden status' do
        get api_order_statistics_path
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when logged in with permission' do
      before do
        create(:permission, user: user, controller: 'api/order_statistics', action: 'index')
        login(user, 'password')
      end

      it 'allows access' do
        get api_order_statistics_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
