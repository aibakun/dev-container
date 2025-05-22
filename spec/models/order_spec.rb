require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    let(:order) { build(:order) }

    it 'is valid with valid attributes' do
      expect(order).to be_valid
    end

    it 'is invalid without an order_date' do
      order.order_date = nil
      expect(order).not_to be_valid
    end
  end

  describe 'associations' do
    let(:order) { create(:order) }

    it 'belongs to a user' do
      expect(order).to respond_to(:user)
    end

    it 'has many order_items' do
      expect(order).to respond_to(:order_items)
    end

    it 'has many products through order_items' do
      expect(order).to respond_to(:products)
    end

    it 'has one order_cancel' do
      expect(order).to respond_to(:order_cancel)
    end

    it 'has one shipment' do
      expect(order).to respond_to(:shipment)
    end

    it 'destroys dependent order_items' do
      order_with_items = create(:order, :with_items)
      expect { order_with_items.destroy }.to change { OrderItem.count }.by(-2)
    end
  end

  describe 'scopes' do
    let!(:active_order) { create(:order) }
    let!(:cancelled_order) { create(:order, :cancelled) }

    describe '.active' do
      it 'returns only non-cancelled orders' do
        expect(Order.active).to include(active_order)
        expect(Order.active).not_to include(cancelled_order)
      end
    end

    describe '.cancelled' do
      it 'returns only cancelled orders' do
        expect(Order.cancelled).to include(cancelled_order)
        expect(Order.cancelled).not_to include(active_order)
      end
    end
  end
end
