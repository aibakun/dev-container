require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  describe 'validations' do
    let(:api_token) { build(:api_token) }

    it 'is valid with user association' do
      expect(api_token).to be_valid
    end

    it 'is not valid without user' do
      api_token.user = nil
      expect(api_token).not_to be_valid
    end
  end

  describe 'token generation' do
    it 'generates token on creation' do
      api_token = create(:api_token)
      expect(api_token.token).to be_present
    end

    it 'generates unique tokens' do
      first_token = create(:api_token)
      second_token = create(:api_token)
      expect(first_token.token).not_to eq(second_token.token)
    end

    it 'can regenerate token' do
      api_token = create(:api_token)
      old_token = api_token.token
      api_token.regenerate_token
      expect(api_token.token).not_to eq(old_token)
    end
  end

  describe '#authenticate' do
    let(:api_token) { create(:api_token) }

    it 'returns true for valid token' do
      expect(api_token.authenticate(api_token.token)).to be true
    end

    it 'returns false for invalid token' do
      expect(api_token.authenticate('invalid_token')).to be false
    end

    it 'returns false for nil token' do
      expect(api_token.authenticate(nil)).to be false
    end

    it 'uses secure comparison' do
      allow(ActiveSupport::SecurityUtils).to receive(:secure_compare).and_return(true)
      api_token.authenticate(api_token.token)
      expect(ActiveSupport::SecurityUtils).to have_received(:secure_compare)
    end
  end
end
