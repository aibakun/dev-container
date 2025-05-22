RSpec.describe 'Carts', type: :request do
  let(:user) { create(:user) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'carts', action: 'show')
  end

  describe 'GET /cart' do
    it 'returns successful response' do
      get cart_path
      expect(response).to have_http_status(:success)
    end
  end
end
