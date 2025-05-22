require 'rails_helper'

RSpec.describe CartItem do
  let(:product) { create(:product) }
  let(:cart_item) { CartItem.new(product: product, quantity: 1) }

  describe 'validations' do
    it 'requires a product' do
      cart_item.product = nil
      expect(cart_item).to be_invalid
    end

    it 'requires a quantity' do
      cart_item.quantity = nil
      expect(cart_item).to be_invalid
    end

    it 'is invalid with zero quantity' do
      cart_item.quantity = 0
      expect(cart_item).to be_invalid
    end

    it 'is invalid with negative quantity' do
      cart_item.quantity = -1
      expect(cart_item).to be_invalid
    end
  end
end
