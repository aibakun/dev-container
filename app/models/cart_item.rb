class CartItem
  include ActiveModel::Model

  attr_accessor :product, :quantity

  validates :product, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
