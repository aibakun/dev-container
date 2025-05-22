require 'rails_helper'

RSpec.describe Orders::MonthlyStatisticsQuery do
  describe '.call' do
    let(:user) { create(:user) }

    context 'with multiple orders' do
      before do
        create(:order, user: user, order_date: 2.months.ago)
        create(:order, user: user, order_date: 1.month.ago)
        create(:order, user: user, order_date: Time.current)
        create(:order, :cancelled, user: user, order_date: 1.month.ago)
      end

      it 'returns monthly statistics' do
        result = described_class.call

        expect(result.keys.length).to be <= 12
        expect(result.values.sum).to eq(3)

        current_month = Time.current.beginning_of_month.to_date
        last_month = 1.month.ago.beginning_of_month.to_date

        expect(result[current_month]).to eq(1)
        expect(result[last_month]).to eq(1)
      end

      it 'orders results by month ascending' do
        result = described_class.call
        expect(result.keys).to eq(result.keys.sort)
      end
    end

    context 'with no orders' do
      it 'returns empty hash' do
        expect(described_class.call).to be_empty
      end
    end
  end
end
