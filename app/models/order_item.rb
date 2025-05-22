class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_sales_info
  has_one :product, through: :product_sales_info

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :order, presence: true
  validates :product_sales_info, presence: true
end
