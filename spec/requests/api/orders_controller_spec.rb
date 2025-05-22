require 'rails_helper'

RSpec.describe 'Api::Orders', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:product_sales_info) { create(:product_sales_info, product: product) }
  let!(:inventory) { create(:inventory, product: product, quantity: 50) }

  before do
    create(:permission, user: user, controller: 'api/orders', action: 'create')
    login(user, 'password')
  end

  describe 'POST /api/orders' do
    let(:valid_params) do
      {
        order: {
          items: [
            { product_sales_info_id: product_sales_info.id, quantity: 2 }
          ]
        }
      }
    end

    context 'when request is valid' do
      it 'creates a new order' do
        expect do
          post api_orders_path, params: valid_params
          expect(response).to have_http_status(:created)
        end.to change(Order, :count).by(1)
      end
    end

    context 'when inventory is insufficient' do
      before { inventory.update!(quantity: 1) }

      it 'returns error' do
        post api_orders_path, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when order has no items' do
      it 'returns error' do
        post api_orders_path, params: { order: { items: [] } }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
