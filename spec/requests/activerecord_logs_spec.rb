require 'rails_helper'

RSpec.describe 'ActiverecordLogs', type: :request do
  let!(:user) do
    create(:user, email: 'shoki.surface+test@gmail.com', password: 'password', password_confirmation: 'password')
  end

  before do
    create(:permission, user: user, controller: 'activerecord_logs', action: 'show')
  end

  describe 'Access control' do
    context 'when not logged in' do
      it 'redirects to the login page when trying to access activerecord logs page' do
        get '/activerecord_logs'
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in' do
      before do
        login(user, 'password')
      end

      it 'allows access to activerecord logs page' do
        get '/activerecord_logs'
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'Logout behavior' do
    before do
      login(user, 'password')
      delete logout_path
    end

    it 'redirects to the login page when trying to access activerecord logs page after logout' do
      get '/activerecord_logs'
      expect(response).to redirect_to(login_path)
    end
  end
end
