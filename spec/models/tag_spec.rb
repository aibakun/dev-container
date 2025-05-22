require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { build(:tag) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(tag).to be_valid
    end

    it 'is not valid without a name' do
      tag.name = nil
      expect(tag).to_not be_valid
    end

    it 'is not valid with a duplicate name' do
      create(:tag, name: tag.name)
      expect(tag).to_not be_valid
    end
  end

  describe 'associations' do
    it 'has many post_tags' do
      expect(tag).to respond_to(:post_tags)
    end

    it 'has many posts through post_tags' do
      expect(tag).to respond_to(:posts)
    end
  end
end
