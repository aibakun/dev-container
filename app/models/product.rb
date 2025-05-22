class Product < ApplicationRecord
  include Paginatable
  has_many :product_sales_infos
  has_one :product_sales_info, lambda {
    where(discontinued: false)
      .where('effective_from <= ?', Time.current)
      .order(effective_from: :desc)
  }
  has_many :order_items
  has_many :orders, through: :order_items
  has_one :inventory, dependent: :destroy

  enum :category, { food: 0, electronics: 10, clothing: 20, other: 30 }

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
end
