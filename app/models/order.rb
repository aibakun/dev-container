class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :delete_all
  has_many :products, through: :order_items
  has_one :order_cancel
  has_one :shipment, dependent: :destroy

  validates :order_date, presence: true
  validate :must_have_at_least_one_valid_item

  scope :active, -> { where.not(id: OrderCancel.select(:order_id)) }
  scope :cancelled, -> { where(id: OrderCancel.select(:order_id)) }

  private

  def must_have_at_least_one_valid_item
    return unless order_items.none? { |item| item.product_sales_info_id.present? && item.quantity.present? }

    errors.add(:base, :no_items_selected)
  end
end
