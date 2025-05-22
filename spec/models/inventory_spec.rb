require 'rails_helper'

RSpec.describe Inventory, type: :model do
  let(:product) { create(:product) }
  let(:inventory) { create(:inventory, product: product) }

  context 'associations' do
    it 'belongs to a product' do
      expect(inventory.product).to eq(product)
    end
  end

  context 'validations' do
    context 'presence' do
      it 'is invalid without a product' do
        inventory.product = nil
        expect(inventory).to be_invalid
      end

      it 'is invalid without a quantity' do
        inventory.quantity = nil
        expect(inventory).to be_invalid
      end
    end

    context 'quantity validation' do
      it 'is invalid with a quantity less than 0' do
        inventory.quantity = -1
        expect(inventory).to be_invalid
      end
    end

    context 'uniqueness' do
      it 'validates uniqueness of product_id' do
        existing_inventory = create(:inventory)
        new_inventory = build(:inventory, product: existing_inventory.product)
        expect(new_inventory).to be_invalid
      end
    end
  end

  describe '#update_quantity!' do
    let(:inventory) { create(:inventory, quantity: 20) }

    it 'updates the quantity with locking' do
      inventory.update_quantity!(15)
      expect(inventory.reload.quantity).to eq(15)
    end

    it 'raises OutOfStockError when quantity would become negative' do
      expect do
        inventory.update_quantity!(-1)
      end.to raise_error(Inventory::OutOfStockError)
    end

    it 'handles concurrent updates safely' do
      thread1 = Thread.new { inventory.update_quantity!(5) }
      thread2 = Thread.new { inventory.update_quantity!(0) }
      [thread1, thread2].each(&:join)
      inventory.reload
      expect(inventory.quantity).to be_in([0, 5])
    end
  end

  describe 'stock status methods' do
    let(:inventory) { create(:inventory) }

    describe '#low_stock?' do
      it 'returns true when quantity is between 1 and 10' do
        inventory.quantity = 10
        expect(inventory).to be_low_stock

        inventory.quantity = 1
        expect(inventory).to be_low_stock
      end

      it 'returns false when quantity is 0 or above threshold' do
        inventory.quantity = 0
        expect(inventory).not_to be_low_stock

        inventory.quantity = 11
        expect(inventory).not_to be_low_stock
      end
    end

    describe '#out_of_stock?' do
      it 'returns true when quantity is 0' do
        inventory.quantity = 0
        expect(inventory).to be_out_of_stock
      end

      it 'returns false when quantity is above 0' do
        inventory.quantity = 1
        expect(inventory).not_to be_out_of_stock
      end
    end
  end
end
