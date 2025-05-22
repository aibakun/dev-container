require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    let(:order_item) { build(:order_item) }

    it 'is valid with valid attributes' do
      expect(order_item).to be_valid
    end

    it 'is invalid without a quantity' do
      order_item.quantity = nil
      expect(order_item).not_to be_valid
    end

    it 'is invalid with a quantity less than or equal to 0' do
      order_item.quantity = 0
      expect(order_item).not_to be_valid
    end

    it 'is invalid without an order' do
      order_item.order = nil
      expect(order_item).not_to be_valid
    end

    it 'is invalid without a product_sales_info' do
      order_item.product_sales_info = nil
      expect(order_item).not_to be_valid
    end
  end

  describe 'associations' do
    let(:order_item) { create(:order_item) }

    it 'belongs to an order' do
      expect(order_item).to respond_to(:order)
    end

    it 'belongs to a product_sales_info' do
      expect(order_item).to respond_to(:product_sales_info)
    end

    it 'has one product through product_sales_info' do
      expect(order_item).to respond_to(:product)
    end
  end
end
