require 'rails_helper'

RSpec.describe 'Permissions', type: :request do
  let(:user_with_full_access) { create(:user) }
  let(:user_with_limited_access) { create(:user) }
  let(:user_without_access) { create(:user) }

  before do
    create(:permission, user: user_with_full_access, controller: 'permissions', action: 'index')
    create(:permission, user: user_with_full_access, controller: 'permissions', action: 'create')
    create(:permission, user: user_with_full_access, controller: 'permissions', action: 'update')
    create(:permission, user: user_with_full_access, controller: 'permissions', action: 'destroy')

    create(:permission, user: user_with_limited_access, controller: 'permissions', action: 'index')
    create(:permission, user: user_with_limited_access, controller: 'permissions', action: 'create')
  end

  describe 'GET /permissions' do
    context 'when user has permission' do
      before { login(user_with_full_access, 'password') }

      it 'returns a successful response' do
        get permissions_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user has limited permission' do
      before { login(user_with_limited_access, 'password') }

      it 'returns a successful response' do
        get permissions_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user does not have permission' do
      before { login(user_without_access, 'password') }

      it 'returns a forbidden response' do
        get permissions_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /permissions' do
    let(:valid_attributes) { { user_id: user_without_access.id, controller: 'users', action: 'index' } }

    context 'when user has permission' do
      before { login(user_with_full_access, 'password') }

      it 'creates a new Permission' do
        expect do
          post permissions_path, params: { permission: valid_attributes }
        end.to change(Permission, :count).by(1)
      end

      it 'redirects to the permissions index' do
        post permissions_path, params: { permission: valid_attributes }
        expect(response).to redirect_to(permissions_path)
      end
    end

    context 'when user has limited permission including create' do
      before { login(user_with_limited_access, 'password') }

      it 'creates a new Permission' do
        expect do
          post permissions_path, params: { permission: valid_attributes }
        end.to change(Permission, :count).by(1)
      end
    end

    context 'when user does not have permission' do
      before { login(user_without_access, 'password') }

      it 'does not create a new Permission' do
        expect do
          post permissions_path, params: { permission: valid_attributes }
        end.not_to change(Permission, :count)
      end

      it 'returns a forbidden response' do
        post permissions_path, params: { permission: valid_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /permissions/:id' do
    let(:permission) { create(:permission, user: user_without_access, controller: 'users', action: 'index') }
    let(:new_attributes) { { action: 'show' } }

    context 'when user has permission' do
      before { login(user_with_full_access, 'password') }

      it 'updates the permission' do
        patch permission_path(permission), params: { permission: new_attributes }
        permission.reload
        expect(permission.action).to eq('show')
      end

      it 'redirects to the permissions index' do
        patch permission_path(permission), params: { permission: new_attributes }
        expect(response).to redirect_to(permissions_path)
      end
    end

    context 'when user has limited permission not including update' do
      before { login(user_with_limited_access, 'password') }

      it 'does not update the permission' do
        patch permission_path(permission), params: { permission: new_attributes }
        permission.reload
        expect(permission.action).not_to eq('show')
      end

      it 'returns a forbidden response' do
        patch permission_path(permission), params: { permission: new_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /permissions/:id' do
    let!(:permission) { create(:permission, user: user_without_access, controller: 'users', action: 'index') }

    context 'when user has permission' do
      before { login(user_with_full_access, 'password') }

      it 'destroys the permission' do
        expect do
          delete permission_path(permission)
        end.to change(Permission, :count).by(-1)
      end

      it 'redirects to the permissions index' do
        delete permission_path(permission)
        expect(response).to redirect_to(permissions_path)
      end
    end

    context 'when user has limited permission not including destroy' do
      before { login(user_with_limited_access, 'password') }

      it 'does not destroy the permission' do
        expect do
          delete permission_path(permission)
        end.not_to change(Permission, :count)
      end

      it 'returns a forbidden response' do
        delete permission_path(permission)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
