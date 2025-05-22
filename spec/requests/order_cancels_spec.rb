require 'rails_helper'

RSpec.describe 'OrderCancels', type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order, :with_items, user: user) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'order_cancels', action: 'new')
    create(:permission, user: user, controller: 'order_cancels', action: 'create')
    create(:permission, user: user, controller: 'order_cancels', action: 'destroy')
  end

  describe 'GET /orders/:order_id/order_cancels/new' do
    it 'returns a successful response' do
      get new_order_order_cancel_path(order)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /orders/:order_id/order_cancels' do
    let(:valid_params) do
      {
        order_cancel: {
          reason: 'お客様都合によるキャンセル'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new order cancel' do
        expect do
          post order_order_cancels_path(order), params: valid_params
        end.to change(OrderCancel, :count).by(1)
      end

      it 'redirects to orders index' do
        post order_order_cancels_path(order), params: valid_params
        expect(response).to redirect_to(orders_path)
      end
    end
  end

  describe 'DELETE /orders/:order_id/order_cancels/:id' do
    let!(:order_cancel) { create(:order_cancel, order: order) }

    it 'destroys the order cancel' do
      expect do
        delete order_order_cancel_path(order, order_cancel)
      end.to change(OrderCancel, :count).by(-1)
    end

    it 'redirects to orders index' do
      delete order_order_cancel_path(order, order_cancel)
      expect(response).to redirect_to(orders_path)
    end
  end
end
