require 'rails_helper'

RSpec.describe 'PurchaseHistories', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    login(user, 'password')

    create(:permission, user: user, controller: 'purchase_histories', action: 'index')
    create(:permission, user: user, controller: 'purchase_histories', action: 'show')
    create(:permission, user: user, controller: 'purchase_histories', action: 'new')
    create(:permission, user: user, controller: 'purchase_histories', action: 'edit')
    create(:permission, user: user, controller: 'purchase_histories', action: 'create')
    create(:permission, user: user, controller: 'purchase_histories', action: 'update')
    create(:permission, user: user, controller: 'purchase_histories', action: 'destroy')
  end

  describe 'GET /purchase_histories' do
    it 'returns a list of purchase histories' do
      create(:purchase_history, user: user)
      create(:purchase_history, user: other_user)

      get purchase_histories_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /purchase_histories/:id' do
    it 'returns a specific purchase history' do
      purchase_history = create(:purchase_history, user: user)

      get purchase_history_path(purchase_history)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /purchase_histories/new' do
    it 'returns the new purchase history form' do
      get new_purchase_history_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /purchase_histories/:id/edit' do
    context 'when accessing own purchase history' do
      it 'returns the edit purchase history form' do
        purchase_history = create(:purchase_history, user: user)

        get edit_purchase_history_path(purchase_history)
        expect(response).to have_http_status(:success)
      end
    end

    context "when accessing other user's purchase history" do
      it 'returns not found status' do
        purchase_history = create(:purchase_history, user: other_user)

        get edit_purchase_history_path(purchase_history)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /purchase_histories' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        {
          name: 'Test Purchase',
          price: 1000,
          purchase_date: Date.current
        }
      end

      it 'creates a new purchase history' do
        expect do
          post purchase_histories_path, params: { purchase_history: valid_attributes }
        end.to change(PurchaseHistory, :count).by(1)

        expect(response).to redirect_to(purchase_histories_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          name: '',
          price: nil,
          purchase_date: nil
        }
      end

      it 'does not create a purchase history' do
        expect do
          post purchase_histories_path, params: { purchase_history: invalid_attributes }
        end.not_to change(PurchaseHistory, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /purchase_histories/:id' do
    context 'when updating own purchase history' do
      context 'with valid parameters' do
        it 'updates the purchase history' do
          purchase_history = create(:purchase_history, user: user)
          new_attributes = { name: 'Updated Purchase', price: 2000 }

          patch purchase_history_path(purchase_history), params: { purchase_history: new_attributes }

          purchase_history.reload
          expect(purchase_history.name).to eq('Updated Purchase')
          expect(purchase_history.price).to eq(2000)
          expect(response).to redirect_to(purchase_histories_path)
        end
      end

      context 'with invalid parameters' do
        it 'does not update the purchase history' do
          purchase_history = create(:purchase_history, user: user)
          invalid_attributes = { name: '', price: nil }

          patch purchase_history_path(purchase_history), params: { purchase_history: invalid_attributes }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when updating other user's purchase history" do
      it 'returns not found status' do
        purchase_history = create(:purchase_history, user: other_user)

        patch purchase_history_path(purchase_history), params: { purchase_history: { name: 'Updated Name' } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /purchase_histories/:id' do
    context 'when deleting own purchase history' do
      it 'deletes the purchase history' do
        purchase_history = create(:purchase_history, user: user)

        expect do
          delete purchase_history_path(purchase_history)
        end.to change(PurchaseHistory, :count).by(-1)

        expect(response).to redirect_to(purchase_histories_path)
      end
    end

    context "when deleting other user's purchase history" do
      it 'does not delete the purchase history' do
        purchase_history = create(:purchase_history, user: other_user)

        expect do
          delete purchase_history_path(purchase_history)
        end.not_to change(PurchaseHistory, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
