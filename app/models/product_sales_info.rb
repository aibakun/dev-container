class ProductSalesInfo < ApplicationRecord
  belongs_to :product
  has_many :order_items
  has_one :inventory, through: :product

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :effective_from, presence: true

  delegate :name, to: :product, prefix: false

  scope :current, lambda {
    where('effective_from <= ?', Time.current)
      .order(effective_from: :desc)
  }
  scope :active, -> { where(discontinued: false) }

  def display_text
    base_text = "#{name} (#{ActiveSupport::NumberHelper.number_to_currency(price, unit: '¥', precision: 0)})"

    if inventory.out_of_stock?
      "#{base_text} (#{I18n.t('inventory.status.out_of_stock')})"
    elsif inventory.low_stock?
      "#{base_text} (#{I18n.t('inventory.status.low_stock', quantity: inventory.quantity)})"
    else
      base_text
    end
  end
end
