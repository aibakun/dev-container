require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  let(:user) { create(:user) }

  before do
    login(user, 'password')

    create(:permission, user: user, controller: 'tags', action: 'create')
    create(:permission, user: user, controller: 'tags', action: 'update')
    create(:permission, user: user, controller: 'tags', action: 'destroy')
  end

  describe 'POST /tags' do
    context 'with valid parameters' do
      let(:valid_attributes) { { name: 'New Tag' } }

      it 'creates a new tag' do
        expect do
          post tags_path, params: { tag: valid_attributes }
        end.to change(Tag, :count).by(1)
      end

      it 'redirects to the created tag' do
        post tags_path, params: { tag: valid_attributes }
        expect(response).to redirect_to(tag_path(Tag.last))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not create a new tag' do
        expect do
          post tags_path, params: { tag: invalid_attributes }
        end.to change(Tag, :count).by(0)
      end

      it 'returns an unprocessable entity status' do
        post tags_path, params: { tag: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with duplicate tag name' do
      let!(:existing_tag) { create(:tag, name: 'Existing Tag') }
      let(:duplicate_attributes) { { name: 'Existing Tag' } }

      it 'does not create a new tag' do
        expect do
          post tags_path, params: { tag: duplicate_attributes }
        end.to change(Tag, :count).by(0)
      end

      it 'returns an unprocessable entity status' do
        post tags_path, params: { tag: duplicate_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /tags/:id' do
    let(:tag) { create(:tag) }

    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Tag' } }

      it 'updates the requested tag' do
        patch tag_path(tag), params: { tag: new_attributes }
        tag.reload
        expect(tag.name).to eq('Updated Tag')
      end

      it 'redirects to the tag' do
        patch tag_path(tag), params: { tag: new_attributes }
        expect(response).to redirect_to(tag_path(tag))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the tag' do
        patch tag_path(tag), params: { tag: invalid_attributes }
        tag.reload
        expect(tag.name).not_to eq('')
      end

      it 'returns an unprocessable entity status' do
        patch tag_path(tag), params: { tag: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with duplicate tag name' do
      let!(:existing_tag) { create(:tag, name: 'Existing Tag') }
      let(:duplicate_attributes) { { name: 'Existing Tag' } }

      it 'does not update the tag' do
        patch tag_path(tag), params: { tag: duplicate_attributes }
        tag.reload
        expect(tag.name).not_to eq('Existing Tag')
      end

      it 'returns an unprocessable entity status' do
        patch tag_path(tag), params: { tag: duplicate_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /tags/:id' do
    let(:tag) { create(:tag) }
    let(:new_attributes) { { name: 'Updated Tag' } }

    it 'updates the requested tag' do
      put tag_path(tag), params: { tag: new_attributes }
      tag.reload
      expect(tag.name).to eq('Updated Tag')
    end

    it 'redirects to the tag' do
      put tag_path(tag), params: { tag: new_attributes }
      expect(response).to redirect_to(tag_path(tag))
    end
  end

  describe 'DELETE /tags/:id' do
    let!(:tag) { create(:tag) }

    it 'destroys the requested tag' do
      expect do
        delete tag_path(tag)
      end.to change(Tag, :count).by(-1)
    end

    it 'redirects to the tags list' do
      delete tag_path(tag)
      expect(response).to redirect_to(tags_url)
    end
  end
end
