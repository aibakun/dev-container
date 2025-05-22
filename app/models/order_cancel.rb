class OrderCancel < ApplicationRecord
  belongs_to :order

  validates :order_id, presence: true, uniqueness: true
end
