require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    let(:product) { build(:product) }

    it 'is valid with valid attributes' do
      expect(product).to be_valid
    end

    it 'is invalid without a name' do
      product.name = nil
      expect(product).not_to be_valid
    end

    it 'is invalid with a duplicate name' do
      create(:product, name: 'Test Product')
      product.name = 'Test Product'
      expect(product).not_to be_valid
    end

    it 'is invalid without a category' do
      product.category = nil
      expect(product).not_to be_valid
    end
  end

  describe 'associations' do
    let(:product) { create(:product) }

    it 'has many product_sales_infos' do
      expect(product).to respond_to(:product_sales_infos)
    end

    it 'has many order_items' do
      expect(product).to respond_to(:order_items)
    end

    it 'has many orders through order_items' do
      expect(product).to respond_to(:orders)
    end
  end

  describe 'enums' do
    it 'defines correct category values' do
      expect(Product.categories).to eq({
                                         'food' => 0,
                                         'electronics' => 10,
                                         'clothing' => 20,
                                         'other' => 30
                                       })
    end
  end
end
