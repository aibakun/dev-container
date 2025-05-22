class PurchaseHistory < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :purchase_date, presence: true
  validates :price, presence: true, numericality: { greater_than: 0, only_integer: true }
end
