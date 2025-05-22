require 'rails_helper'

RSpec.describe UnnormalizedPurchaseHistory, type: :model do
  let(:purchase_history) { build(:unnormalized_purchase_history) }

  describe 'validations' do
    it 'requires a user_name' do
      purchase_history.user_name = nil
      expect(purchase_history).to be_invalid
    end

    it 'requires a user_email' do
      purchase_history.user_email = nil
      expect(purchase_history).to be_invalid
    end

    it 'requires a product_name' do
      purchase_history.product_name = nil
      expect(purchase_history).to be_invalid
    end

    it 'requires a product_price' do
      purchase_history.product_price = nil
      expect(purchase_history).to be_invalid
    end

    it 'is invalid with zero product_price' do
      purchase_history.product_price = 0
      expect(purchase_history).to be_invalid
    end

    it 'requires a quantity' do
      purchase_history.quantity = nil
      expect(purchase_history).to be_invalid
    end

    it 'is invalid with zero quantity' do
      purchase_history.quantity = 0
      expect(purchase_history).to be_invalid
    end

    it 'requires a category_name' do
      purchase_history.category_name = nil
      expect(purchase_history).to be_invalid
    end

    it 'requires a purchase_date' do
      purchase_history.purchase_date = nil
      expect(purchase_history).to be_invalid
    end
  end

  describe 'factory traits' do
    context 'with low price trait' do
      let(:purchase_history) { build(:unnormalized_purchase_history, :with_low_price) }
      it 'creates record with price less than 1000' do
        expect(purchase_history.product_price).to be < 1000
        expect(purchase_history).to be_valid
      end
    end

    context 'with high quantity trait' do
      let(:purchase_history) { build(:unnormalized_purchase_history, :with_high_quantity) }
      it 'creates record with quantity greater than 10' do
        expect(purchase_history.quantity).to be > 10
        expect(purchase_history).to be_valid
      end
    end

    context 'with old purchase trait' do
      let(:purchase_history) { build(:unnormalized_purchase_history, :old_purchase) }
      it 'creates record with date older than 6 months' do
        expect(purchase_history.purchase_date).to be < 6.months.ago
        expect(purchase_history).to be_valid
      end
    end

    context 'with invalid email trait' do
      let(:purchase_history) { build(:unnormalized_purchase_history, :invalid_email) }
      it 'creates valid record' do
        expect(purchase_history).to be_valid
      end
    end

    context 'with zero price trait' do
      let(:purchase_history) { build(:unnormalized_purchase_history, :zero_price) }
      it 'creates invalid record' do
        expect(purchase_history).to be_invalid
      end
    end

    context 'with negative quantity trait' do
      let(:purchase_history) { build(:unnormalized_purchase_history, :negative_quantity) }
      it 'creates invalid record' do
        expect(purchase_history).to be_invalid
      end
    end
  end

  describe 'multiple records' do
    before do
      create(:unnormalized_purchase_history, :old_purchase)
      create(:unnormalized_purchase_history,
             purchase_date: 1.day.ago,
             user_name: 'testuser',
             user_email: 'shoki.surface@gmail.com',
             product_name: 'Premium Tea',
             product_price: 1200,
             quantity: 3,
             category_name: 'Beverages')
      create(:unnormalized_purchase_history,
             purchase_date: Time.current,
             user_name: 'testuser',
             user_email: 'shoki.surface@gmail.com',
             product_name: 'Organic Chips',
             product_price: 800,
             quantity: 4,
             category_name: 'Snacks')
    end

    it 'creates all records' do
      expect(UnnormalizedPurchaseHistory.count).to eq(3)
    end
  end
end
