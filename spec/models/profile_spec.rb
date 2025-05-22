require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user) { create(:user) }
  let(:profile) { build(:profile, user: user) }

  describe 'associations' do
    it 'belongs to user' do
      expect(profile.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'requires a biography' do
      profile.biography = nil
      expect(profile).to be_invalid
    end

    it 'requires a user' do
      profile.user = nil
      expect(profile).to be_invalid
    end
  end
end
