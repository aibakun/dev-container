require 'rails_helper'

RSpec.describe PurchaseHistory, type: :model do
  let(:user) { create(:user) }
  let(:purchase_history) { create(:purchase_history, user: user) }

  describe 'associations' do
    it 'belongs to user' do
      expect(purchase_history.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'requires a name' do
      purchase_history.name = nil
      expect(purchase_history).to be_invalid
    end

    it 'requires a price' do
      purchase_history.price = nil
      expect(purchase_history).to be_invalid
    end

    it 'is invalid with negative price' do
      purchase_history.price = -1
      expect(purchase_history).to be_invalid
    end

    it 'is invalid with decimal price' do
      purchase_history.price = 100.1
      expect(purchase_history).to be_invalid
    end

    it 'requires a user' do
      purchase_history.user = nil
      expect(purchase_history).to be_invalid
    end

    it 'requires a purchase_date' do
      purchase_history.purchase_date = nil
      expect(purchase_history).to be_invalid
    end
  end
end
