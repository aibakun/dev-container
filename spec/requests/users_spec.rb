require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user, profile: create(:profile)) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'users', action: 'index')
    create(:permission, user: user, controller: 'users', action: 'show')
    create(:permission, user: user, controller: 'users', action: 'new')
    create(:permission, user: user, controller: 'users', action: 'edit')
    create(:permission, user: user, controller: 'users', action: 'create')
    create(:permission, user: user, controller: 'users', action: 'update')
    create(:permission, user: user, controller: 'users', action: 'destroy')
  end

  describe 'GET /users' do
    it 'returns a list of users' do
      get users_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:id' do
    it 'returns a specific user' do
      get user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/new' do
    it 'returns the new user form' do
      get new_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:id/edit' do
    it 'returns the edit user form' do
      get edit_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /users' do
    context 'with valid parameters' do
      let(:valid_params) { { user: attributes_for(:user), profile: attributes_for(:profile) } }

      it 'creates a new user and profile' do
        expect do
          post users_path, params: valid_params
        end.to change(User, :count).by(1).and change(Profile, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_user_params) { { user: attributes_for(:user, name: '') } }
      let(:invalid_profile_params) do
        {
          user: attributes_for(:user),
          profile: attributes_for(:profile, biography: '')
        }
      end

      it 'returns error for invalid user params' do
        expect do
          post users_path, params: invalid_user_params
        end.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for invalid profile params' do
        expect do
          post users_path, params: invalid_profile_params
        end.to change(User, :count).by(0).and change(Profile, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when error occurs' do
      let(:valid_params) { { user: attributes_for(:user), profile: attributes_for(:profile) } }

      it 'handles unexpected errors' do
        allow_any_instance_of(User).to receive(:save!).and_raise(StandardError.new('Unexpected error'))

        expect do
          post users_path, params: valid_params
        end.not_to change(User, :count)

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'handles validation errors' do
        allow_any_instance_of(User).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(User.new))

        expect do
          post users_path, params: valid_params
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /users/:id' do
    context 'with valid parameters' do
      let(:user_with_profile) { create(:user, profile: create(:profile)) }

      it 'updates the user attributes' do
        patch user_path(user_with_profile), params: { user: { name: 'Updated User' } }
        expect(user_with_profile.reload.name).to eq('Updated User')
      end

      it 'updates the user profile' do
        patch user_path(user_with_profile), params: {
          user: { name: user_with_profile.name },
          profile: { biography: 'Updated Biography' }
        }
        expect(user_with_profile.reload.profile.biography).to eq('Updated Biography')
      end
    end

    context 'with invalid parameters' do
      let(:user_with_profile) { create(:user, profile: create(:profile)) }
      let(:invalid_user_params) { { user: attributes_for(:user, name: '') } }
      let(:invalid_profile_params) do
        {
          user: { name: user_with_profile.name },
          profile: { biography: '' }
        }
      end

      it 'returns error for invalid user params' do
        patch user_path(user_with_profile), params: invalid_user_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for invalid profile params' do
        original_biography = user_with_profile.profile.biography

        patch user_path(user_with_profile), params: invalid_profile_params

        expect(user_with_profile.reload.profile.biography).to eq(original_biography)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /users/:id' do
    context 'when user exists' do
      let!(:user_to_delete) { create(:user, profile: create(:profile)) }

      it 'deletes a user and associated profile' do
        expect do
          delete user_path(user_to_delete)
        end.to change(User, :count).by(-1).and change(Profile, :count).by(-1)
      end
    end
  end
end
