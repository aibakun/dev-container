class Inventory < ApplicationRecord
  class OutOfStockError < StandardError; end

  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: true

  def update_quantity!(new_quantity)
    with_lock do
      raise(OutOfStockError, 'Sorry, this item is currently out of stock') if new_quantity.negative?

      self.quantity = new_quantity
      save!
    end
  end

  def low_stock?
    quantity <= 10 && quantity.positive?
  end

  def out_of_stock?
    quantity.zero?
  end
end
