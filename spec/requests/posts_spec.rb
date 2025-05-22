require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:post) { create(:post, user: user) }
  let!(:other_post) { create(:post, user: other_user) }
  let(:tag1) { create(:tag) }
  let(:tag2) { create(:tag) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'posts', action: 'index')
    create(:permission, user: user, controller: 'posts', action: 'show')
    create(:permission, user: user, controller: 'posts', action: 'new')
    create(:permission, user: user, controller: 'posts', action: 'edit')
    create(:permission, user: user, controller: 'posts', action: 'create')
    create(:permission, user: user, controller: 'posts', action: 'update')
    create(:permission, user: user, controller: 'posts', action: 'destroy')
  end

  describe 'GET /users/:user_id/posts' do
    it 'lists all posts for a user' do
      get user_posts_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:user_id/posts/:id' do
    it 'shows a specific post' do
      get user_post_path(user, post)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:user_id/posts/new' do
    it 'returns the new post form' do
      get new_user_post_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:user_id/posts/:id/edit' do
    it 'returns the edit post form' do
      get edit_user_post_path(user, post)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /users/:id/posts' do
    context 'with valid parameters' do
      let(:valid_params) { { post: attributes_for(:post) } }

      it 'creates a post' do
        expect do
          process :post, user_posts_path(user), params: valid_params
        end.to change(Post, :count).by(1)

        expect(response).to redirect_to(user_post_path(user, Post.last))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { post: attributes_for(:post, title: '') } }

      it 'fails to create a post' do
        expect do
          process :post, user_posts_path(user), params: invalid_params
        end.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with tags' do
      let(:params_with_tags) { { post: attributes_for(:post, tag_ids: [tag1.id.to_s, tag2.id.to_s]) } }

      it 'creates a post with tags' do
        expect do
          process :post, user_posts_path(user), params: params_with_tags
        end.to change(Post, :count).by(1)
                                   .and change(PostTag, :count).by(2)

        expect(Post.last.tags).to include(tag1, tag2)
      end

      it 'ignores non-existent tag ids' do
        non_existent_tag_id = Tag.maximum(:id).to_i + 1
        params_with_bad_tag = {
          post: attributes_for(:post, tag_ids: [tag1.id, non_existent_tag_id])
        }

        expect do
          process :post, user_posts_path(user), params: params_with_bad_tag
        end.to change(Post, :count).by(1)

        expect(Post.last.tags).to contain_exactly(tag1)
      end

      it 'handles duplicate tag ids' do
        params_with_duplicate_tags = {
          post: attributes_for(:post, tag_ids: [tag1.id, tag1.id, tag2.id])
        }

        expect do
          process :post, user_posts_path(user), params: params_with_duplicate_tags
        end.to change(Post, :count).by(1)

        expect(Post.last.tags).to contain_exactly(tag1, tag2)
      end
    end
  end

  describe 'PATCH /users/:user_id/posts/:id' do
    context 'with valid parameters' do
      let(:valid_params) { { post: attributes_for(:post, title: 'Updated Title') } }

      it 'updates the post' do
        patch user_post_path(user, post), params: valid_params

        post.reload
        expect(post.title).to eq('Updated Title')
        expect(response).to redirect_to(user_post_path(user, post))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { post: attributes_for(:post, title: '') } }

      it 'fails to update the post' do
        expect do
          patch user_post_path(user, post), params: invalid_params
        end.not_to(change { post.reload.title })

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with another user's post" do
      let(:valid_params) { { post: attributes_for(:post, title: 'Updated Title') } }

      it "can't update another user's post" do
        expect do
          patch user_post_path(other_user, other_post), params: valid_params
        end.not_to(change { other_post.reload.attributes })

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when updating tags' do
      let(:new_tag) { create(:tag) }

      it "updates the post's tags" do
        patch user_post_path(user, post), params: { post: { tag_ids: [new_tag.id] } }

        post.reload
        expect(post.tags).to include(new_tag)
      end

      it 'removes all tags when tag_ids is empty' do
        post.tags << [tag1, tag2]

        patch user_post_path(user, post), params: { post: { tag_ids: [] } }

        post.reload
        expect(post.tags).to be_empty
      end
    end
  end

  describe 'DELETE /users/:user_id/posts/:id' do
    context 'as the post owner' do
      it 'deletes the post' do
        expect do
          delete user_post_path(user, post)
        end.to change(Post, :count).by(-1)

        expect(response).to redirect_to(user_posts_path(user))
      end
    end
  end
end
