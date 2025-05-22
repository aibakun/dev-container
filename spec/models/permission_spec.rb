require 'rails_helper'

RSpec.describe Permission, type: :model do
  let(:user) { create(:user) }
  let(:permission) { build(:permission, user: user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(permission).to be_valid
    end

    it 'is not valid without a controller' do
      permission.controller = nil
      expect(permission).not_to be_valid
    end

    it 'is not valid without an action' do
      permission.action = nil
      expect(permission).not_to be_valid
    end

    it 'is not valid without a user' do
      permission.user = nil
      expect(permission).not_to be_valid
    end

    it 'is not valid with a duplicate combination of user, controller, and action' do
      existing_permission = create(:permission, user: user)
      new_permission = build(:permission,
                             user: user,
                             controller: existing_permission.controller,
                             action: existing_permission.action)
      expect(new_permission).not_to be_valid
    end

    it 'is not valid with a non-existent controller' do
      expect do
        permission.controller = 'non_existent_controller'
        permission.valid?
      end.to raise_error(ArgumentError, 'Controller not found: non_existent_controller')
    end

    it 'is not valid with a non-existent action' do
      permission.action = 'non_existent_action'
      expect(permission).not_to be_valid
    end
  end

  describe '.available_controllers' do
    it 'returns controller names' do
      expect(Permission.available_controllers).to include('users', 'permissions')
      expect(Permission.available_controllers).to include('api/users')
      expect(Permission.available_controllers).not_to include('application', 'rails/health')
    end

    it 'returns namespaced controller names properly' do
      expect(Permission.available_controllers).to include('admin/test')
    end

    it 'excludes internal base controller' do
      expect(Permission.available_controllers).not_to include('api/internal_base')
    end
  end

  describe '.available_actions' do
    it 'returns controller actions' do
      actions = Permission.available_actions('users')
      expect(actions).to include('index', 'show', 'new', 'create', 'edit', 'update', 'destroy')
      expect(actions).not_to include('set_locale')
    end

    it 'returns actions for api controllers' do
      actions = Permission.available_actions('api/users')
      expect(actions).to include('index')
      expect(actions).not_to include(
        'authenticate_or_request_with_http_token',
        'authenticate_with_http_token',
        'request_http_token_authentication'
      )
    end

    it 'returns actions for namespaced controllers' do
      actions = Permission.available_actions('admin/test')
      expect(actions).to include('index', 'show')
    end

    it 'raises ArgumentError for non-existent controller' do
      expect { Permission.available_actions('non_existent') }.to raise_error(ArgumentError)
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      expect(permission.user).to eq(user)
    end
  end
end
