require 'rails_helper'

RSpec.describe OrderCancel, type: :model do
  describe 'validations' do
    let(:order) { create(:order) }
    let(:order_cancel) { build(:order_cancel, order: order) }

    it 'is valid with valid attributes' do
      expect(order_cancel).to be_valid
    end

    it 'is invalid without an order' do
      order_cancel.order = nil
      expect(order_cancel).not_to be_valid
    end

    it 'is invalid with a duplicate order_id' do
      existing_cancel = create(:order_cancel)
      order_cancel.order = existing_cancel.order
      expect(order_cancel).not_to be_valid
    end
  end

  describe 'associations' do
    let(:order_cancel) { create(:order_cancel) }

    it 'belongs to an order' do
      expect(order_cancel).to respond_to(:order)
    end
  end
end
