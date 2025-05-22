require 'rails_helper'

RSpec.describe PurchaseHistories::SearchQuery do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let!(:purchase1) { create(:purchase_history, user: user, name: 'Ruby Book', price: 5000, purchase_date: 1.day.ago) }
  let!(:purchase2) do
    create(:purchase_history, user: user, name: 'Python Book', price: 3000, purchase_date: 2.days.ago)
  end
  let!(:purchase3) do
    create(:purchase_history, user: other_user, name: 'JavaScript Book', price: 4000, purchase_date: 3.days.ago)
  end

  describe '#call' do
    it 'returns all purchase histories when no parameters are provided' do
      results = described_class.new.call({})
      expect(results).to match_array([purchase1, purchase2, purchase3])
    end

    it 'filters by name' do
      results = described_class.new.call(name: 'Ruby')
      expect(results).to contain_exactly(purchase1)
    end

    it 'filters by price range' do
      results = described_class.new.call(min_price: 4000, max_price: 5000)
      expect(results).to contain_exactly(purchase1, purchase3)
    end

    it 'filters by date range' do
      results = described_class.new.call(
        start_date: 2.days.ago.to_date.to_s,
        end_date: Time.current.to_date.to_s
      )
      expect(results).to contain_exactly(purchase1, purchase2)
    end

    it 'filters by user' do
      results = described_class.new.call(user_id: user.id)
      expect(results).to contain_exactly(purchase1, purchase2)
    end

    it 'combines multiple filters' do
      results = described_class.new.call(
        name: 'Ruby',
        min_price: 4000,
        user_id: user.id
      )
      expect(results).to contain_exactly(purchase1)
    end

    it 'handles empty or nil search parameters' do
      results = described_class.new.call(
        name: '',
        min_price: nil,
        max_price: nil,
        start_date: '',
        end_date: '',
        user_id: nil
      )
      expect(results).to match_array([purchase1, purchase2, purchase3])
    end

    it 'ignores case when filtering by name' do
      results = described_class.new.call(name: 'ruby')
      expect(results).to contain_exactly(purchase1)
    end

    it 'handles only min price' do
      results = described_class.new.call(min_price: 4000)
      expect(results).to contain_exactly(purchase1, purchase3)
    end

    it 'handles only max price' do
      results = described_class.new.call(max_price: 3000)
      expect(results).to contain_exactly(purchase2)
    end

    it 'handles only start date' do
      results = described_class.new.call(
        start_date: 2.days.ago.to_date.to_s
      )
      expect(results).to contain_exactly(purchase1, purchase2)
    end

    it 'handles only end date' do
      results = described_class.new.call(
        end_date: 2.days.ago.to_date.to_s
      )
      expect(results).to contain_exactly(purchase2, purchase3)
    end
  end
end
