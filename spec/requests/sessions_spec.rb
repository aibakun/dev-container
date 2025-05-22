require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password') }

  before do
    create(:permission, user: user, controller: 'users', action: 'index')
  end

  describe 'GET /login' do
    it 'returns http success' do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login' do
    it 'logs in with valid credentials and redirects to root' do
      post login_path, params: { email: user.email, password: 'password' }

      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(root_path)
    end

    it 'shows error with invalid credentials' do
      post login_path, params: { email: user.email, password: 'wrong_password' }

      expect(session[:user_id]).to be_nil
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /logout' do
    before { post login_path, params: { email: user.email, password: 'password' } }

    it 'logs the user out and redirects to login' do
      delete logout_path

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'authentication control' do
    it 'redirects to login when trying to access protected resources' do
      get users_path
      expect(response).to redirect_to(login_path)
    end

    it 'allows access to protected resources after login' do
      post login_path, params: { email: user.email, password: 'password' }

      get users_path
      expect(response).to have_http_status(:success)
    end

    it 'redirects to login after logout' do
      post login_path, params: { email: user.email, password: 'password' }

      delete logout_path

      get users_path
      expect(response).to redirect_to(login_path)
    end
  end
end
