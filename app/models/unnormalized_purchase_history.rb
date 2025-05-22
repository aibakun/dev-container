class UnnormalizedPurchaseHistory < ApplicationRecord
  validates :user_name, presence: true
  validates :user_email, presence: true
  validates :product_name, presence: true
  validates :product_price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :category_name, presence: true
  validates :purchase_date, presence: true
end
