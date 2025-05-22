require 'rails_helper'

RSpec.describe ProductSalesInfo, type: :model do
  describe 'validations' do
    let(:product_sales_info) { build(:product_sales_info) }

    it 'is valid with valid attributes' do
      expect(product_sales_info).to be_valid
    end

    it 'is invalid without a price' do
      product_sales_info.price = nil
      expect(product_sales_info).not_to be_valid
    end

    it 'is invalid with a price less than or equal to 0' do
      product_sales_info.price = 0
      expect(product_sales_info).not_to be_valid
    end

    it 'is invalid without an effective_from date' do
      product_sales_info.effective_from = nil
      expect(product_sales_info).not_to be_valid
    end
  end

  describe 'associations' do
    let(:product_sales_info) { create(:product_sales_info) }

    it 'belongs to a product' do
      expect(product_sales_info).to respond_to(:product)
    end

    it 'has many order_items' do
      expect(product_sales_info).to respond_to(:order_items)
    end

    it 'has one inventory through product' do
      expect(product_sales_info).to respond_to(:inventory)
    end
  end

  describe 'delegation' do
    let(:product_sales_info) { create(:product_sales_info) }

    it 'delegates name to product' do
      expect(product_sales_info.name).to eq(product_sales_info.product.name)
    end
  end

  describe 'scopes' do
    let!(:old_info) { create(:product_sales_info, effective_from: 2.days.ago) }
    let!(:current_info) { create(:product_sales_info, effective_from: 1.day.ago) }
    let!(:future_info) { create(:product_sales_info, effective_from: 2.days.from_now) }
    let!(:discontinued_info) { create(:product_sales_info, :discontinued) }

    describe '.current' do
      it 'returns only current and past product sales info ordered by effective_from' do
        result = described_class.current
        expect(result.pluck(:effective_from)).to eq(
          result.pluck(:effective_from).sort.reverse
        )
        expect(result).to include(current_info, old_info)
        expect(result).not_to include(future_info)
      end
    end

    describe '.active' do
      it 'returns only non-discontinued product sales info' do
        expect(described_class.active).not_to include(discontinued_info)
      end
    end
  end

  describe '#display_text' do
    let(:product) { create(:product) }
    let(:product_sales_info) { create(:product_sales_info, product: product, price: 1000) }
    let!(:inventory) { create(:inventory, product: product, quantity: 15) }

    it 'returns basic display text when inventory is sufficient' do
      expected_text = "#{product.name} (¥1,000)"
      expect(product_sales_info.display_text).to eq(expected_text)
    end

    it 'includes out of stock status when inventory quantity is zero' do
      inventory.update(quantity: 0)
      expect(product_sales_info.display_text).to include('在庫なし')
    end

    it 'includes low stock status when inventory quantity is low' do
      inventory.update(quantity: 5)
      expect(product_sales_info.display_text).to include('残り5点')
    end
  end
end
