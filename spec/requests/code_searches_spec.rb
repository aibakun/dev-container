require 'rails_helper'

RSpec.describe 'CodeSearches', type: :request do
  let!(:user) do
    create(:user, email: 'shoki.surface+test@gmail.com', password: 'password', password_confirmation: 'password')
  end

  before do
    create(:permission, user: user, controller: 'code_searches', action: 'show')
  end

  describe 'Access control' do
    context 'when not logged in' do
      it 'redirects to the login page when trying to access code search page' do
        get '/code_searches'
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in' do
      before do
        login(user, 'password')
      end

      it 'allows access to code search page' do
        get '/code_searches'
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'Logout behavior' do
    before do
      login(user, 'password')
      delete logout_path
    end

    it 'redirects to the login page when trying to access code search page after logout' do
      get '/code_searches'
      expect(response).to redirect_to(login_path)
    end
  end
end
