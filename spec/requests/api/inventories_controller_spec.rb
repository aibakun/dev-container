require 'rails_helper'

RSpec.describe 'Api::Inventories', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:inventory) { create(:inventory, product: product, quantity: 50) }

  before do
    create(:permission, user: user, controller: 'api/inventories', action: 'show')
    create(:permission, user: user, controller: 'api/inventories', action: 'update')
    login(user, 'password')
  end

  describe 'GET /api/inventories/:id' do
    context 'when inventory exists' do
      it 'returns inventory information' do
        get api_inventory_path(inventory)

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include(
          'id' => inventory.id,
          'product_id' => product.id,
          'quantity' => 50,
          'low_stock' => false
        )
      end
    end

    context 'when inventory does not exist' do
      it 'returns 404 error' do
        get api_inventory_path(id: 0)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/inventories/:id' do
    context 'when request is valid' do
      it 'updates inventory quantity' do
        patch api_inventory_path(inventory), params: { quantity: 30 }

        expect(response).to have_http_status(:success)
        expect(inventory.reload.quantity).to eq(30)
        expect(response.parsed_body).to include(
          'id' => inventory.id,
          'product_id' => product.id,
          'quantity' => 30,
          'low_stock' => false
        )
      end

      it 'handles string quantity parameter' do
        patch api_inventory_path(inventory), params: { quantity: '25' }

        expect(response).to have_http_status(:success)
        expect(inventory.reload.quantity).to eq(25)
      end

      it 'returns low_stock true when quantity is below threshold' do
        patch api_inventory_path(inventory), params: { quantity: 10 }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['low_stock']).to be true
      end
    end

    context 'when request is invalid' do
      it 'returns 422 error for negative quantity' do
        patch api_inventory_path(inventory), params: { quantity: -1 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('Out of stock')
      end

      it 'returns 404 error when inventory does not exist' do
        patch api_inventory_path(id: 0), params: { quantity: 30 }

        expect(response).to have_http_status(:not_found)
      end

      it 'returns 422 error when out of stock' do
        allow_any_instance_of(Inventory).to receive(:update_quantity!)
          .and_raise(Inventory::OutOfStockError)

        patch api_inventory_path(inventory), params: { quantity: 0 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('Out of stock')
      end
    end

    context 'when concurrent updates occur' do
      it 'handles concurrent requests without deadlock' do
        threads = []
        results = []

        3.times do |i|
          threads << Thread.new do
            patch api_inventory_path(inventory),
                  params: { quantity: 10 - i }
            results << response.status
          end
        end

        threads.each(&:join)

        expect(results).to all(eq(200))
        expect(inventory.reload.quantity).to be_in([8, 9, 10])
      end
    end
  end
end
