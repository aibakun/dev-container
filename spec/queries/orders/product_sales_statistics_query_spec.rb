require 'rails_helper'

RSpec.describe Orders::ProductSalesStatisticsQuery do
  describe '.call' do
    let(:user) { create(:user) }
    let(:sales_info) { create(:product_sales_info, price: 1000) }
    let(:sales_info2) { create(:product_sales_info, price: 2000) }

    context 'with multiple products' do
      before do
        order1 = create(:order, user: user, order_date: 1.day.ago)
        order1.order_items.clear
        order1.order_items.create!(product_sales_info: sales_info, quantity: 2)

        order2 = create(:order, user: user, order_date: 2.days.ago)
        order2.order_items.clear
        order2.order_items.create!(product_sales_info: sales_info2, quantity: 1)
      end

      it 'returns product statistics ordered by total sales' do
        result = described_class.call
        products = result.values.sort_by { |v| -v[:total_sales] }

        expect(products.first[:total_sales]).to eq(2000)
        expect(products.second[:total_sales]).to eq(2000)
      end

      it 'limits results to 10 products' do
        expect(described_class.call.keys.length).to be <= 10
      end
    end

    context 'with cancelled orders' do
      before do
        order = create(:order, user: user, order_date: 1.day.ago)
        order.order_items.clear
        order.order_items.create!(product_sales_info: sales_info, quantity: 1)

        cancelled_order = create(:order, :cancelled, user: user)
        cancelled_order.order_items.clear
        cancelled_order.order_items.create!(product_sales_info: sales_info, quantity: 1)
      end

      it 'excludes cancelled orders from statistics' do
        result = described_class.call
        product = result.values.first

        expect(product[:total_quantity]).to eq(1)
        expect(product[:total_sales]).to eq(1000)
      end
    end

    context 'with no orders' do
      it 'returns empty hash' do
        expect(described_class.call).to be_empty
      end
    end
  end
end
