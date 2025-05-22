require 'rails_helper'

RSpec.describe PostTag, type: :model do
  let(:post) { create(:post) }
  let(:tag) { create(:tag) }
  let(:post_tag) { build(:post_tag, post: post, tag: tag) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(post_tag).to be_valid
    end

    it 'is not valid without a post' do
      post_tag.post = nil
      expect(post_tag).to_not be_valid
    end

    it 'is not valid without a tag' do
      post_tag.tag = nil
      expect(post_tag).to_not be_valid
    end

    it 'is not valid with a duplicate post and tag combination' do
      post_tag.save
      duplicate_post_tag = build(:post_tag, post: post, tag: tag)
      expect(duplicate_post_tag).to_not be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a post' do
      expect(post_tag).to respond_to(:post)
    end

    it 'belongs to a tag' do
      expect(post_tag).to respond_to(:tag)
    end
  end
end
