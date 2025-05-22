require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:post) { build(:post, user: user) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(post).to be_valid
    end

    it 'is not valid without a title' do
      post.title = nil
      expect(post).not_to be_valid
    end

    it 'is not valid without content' do
      post.content = nil
      expect(post).not_to be_valid
    end

    it 'is not valid without a user' do
      post.user = nil
      expect(post).not_to be_valid
    end

    it 'is valid with a title of 20 characters' do
      post.title = 'a' * 20
      expect(post).to be_valid
    end

    it 'is not valid with a title longer than 20 characters' do
      post.title = 'a' * 21
      expect(post).not_to be_valid
    end

    it 'is valid with content of 200 characters' do
      post.content = 'a' * 200
      expect(post).to be_valid
    end

    it 'is not valid with content longer than 200 characters' do
      post.content = 'a' * 201
      expect(post).not_to be_valid
    end
  end

  context 'associations' do
    it 'belongs to a user' do
      expect(post.user).to eq(user)
    end

    it 'has many post_tags' do
      expect(post).to respond_to(:post_tags)
    end

    it 'has many tags through post_tags' do
      expect(post).to respond_to(:tags)
    end
  end

  context 'scopes' do
    it 'orders posts by created_at in descending order' do
      old_post = create(:post, created_at: 1.day.ago)
      new_post = create(:post, created_at: 1.hour.ago)
      expect(Post.recent).to eq([new_post, old_post])
    end

    it 'returns currently published posts' do
      published_post = create(:post, published_at: 1.hour.ago, archived: false)
      draft_post = create(:post, published_at: nil, archived: false)
      scheduled_post = create(:post, published_at: 1.hour.from_now, archived: false)
      archived_post = create(:post, published_at: 1.day.ago, archived: true)
      expect(Post.published).to include(published_post)
      expect(Post.published).not_to include(draft_post, scheduled_post, archived_post)
    end

    it 'returns scheduled posts' do
      scheduled_post = create(:post, published_at: 1.hour.from_now, archived: false)
      published_post = create(:post, published_at: 1.hour.ago, archived: false)
      draft_post = create(:post, published_at: nil, archived: false)
      expect(Post.scheduled).to include(scheduled_post)
      expect(Post.scheduled).not_to include(published_post, draft_post)
    end

    it 'returns draft posts' do
      draft_post = create(:post, published_at: nil, archived: false)
      published_post = create(:post, published_at: 1.hour.ago, archived: false)
      scheduled_post = create(:post, published_at: 1.hour.from_now, archived: false)
      expect(Post.draft).to include(draft_post)
      expect(Post.draft).not_to include(published_post, scheduled_post)
    end

    it 'returns archived posts' do
      archived_post = create(:post, published_at: 1.day.ago, archived: true)
      published_post = create(:post, published_at: 1.hour.ago, archived: false)
      draft_post = create(:post, published_at: nil, archived: false)
      expect(Post.archived).to include(archived_post)
      expect(Post.archived).not_to include(published_post, draft_post)
    end
  end

  context 'publishing methods' do
    it 'publishes a post' do
      post.publish_post
      expect(post).to be_published
      expect(post.published_at).to be_within(1.second).of(Time.current)
      expect(post.archived).to be false
    end

    it 'does not publish a post in the future' do
      future_time = 1.day.from_now
      expect(post.publish_post(future_time)).to be false
      expect(post).not_to be_published
    end

    it 'unpublishes a post' do
      post.publish_post
      post.unpublish_post
      expect(post).to be_draft
      expect(post.published_at).to be_nil
      expect(post.archived).to be false
    end

    it 'schedules a post for future publishing' do
      future_time = 1.day.from_now
      post.schedule_post(future_time)
      expect(post).to be_scheduled
      expect(post.published_at).to be_within(0.001.seconds).of(future_time)
      expect(post.archived).to be false
    end

    it 'does not schedule a post in the past' do
      past_time = 1.day.ago
      expect(post.schedule_post(past_time)).to be false
      expect(post.published_at).to be_nil
    end

    it 'archives a published post' do
      post.publish_post
      post.archive_post
      expect(post).to be_archived
      expect(post.archived).to be true
    end

    it 'does not archive a draft post' do
      expect(post.archive_post).to be false
      expect(post).not_to be_archived
    end

    it 'unarchives a post' do
      post.publish_post
      post.archive_post
      post.unarchive_post
      expect(post).to be_published
      expect(post.archived).to be false
    end

    it 'does not unarchive a non-archived post' do
      expect(post.unarchive_post).to be false
      expect(post).not_to be_published
    end
  end

  context 'status methods' do
    it 'returns true for draft? when not published and not archived' do
      expect(post).to be_draft
    end

    it 'returns true for published? when published in the past and not archived' do
      post.publish_post(1.hour.ago)
      expect(post).to be_published
    end

    it 'returns true for scheduled? when scheduled in the future' do
      post.schedule_post(1.hour.from_now)
      expect(post).to be_scheduled
    end

    it 'returns true for archived? when archived' do
      post.publish_post
      post.archive_post
      expect(post).to be_archived
    end
  end
end
