require 'rails_helper'

RSpec.describe Api::ShipmentsController, type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order) }
  let(:shipment) { create(:shipment, order: order, status: 'preparing') }

  before do
    create(:permission, user: user, controller: 'api/shipments', action: 'update')
    login(user, 'password')
  end

  describe 'PATCH /api/shipments/:id' do
    context 'with valid event' do
      it 'returns 200' do
        patch api_shipment_path(shipment), params: { event: 'ship' }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid event' do
      it 'returns 422' do
        patch api_shipment_path(shipment), params: { event: 'invalid_event' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid transition' do
      it 'returns 422' do
        patch api_shipment_path(shipment), params: { event: 'mark_as_delivered' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
