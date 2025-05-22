FactoryBot.define do
  factory :order_cancel do
    association :order
    reason { %w[在庫切れ お客様都合 その他].sample }

    before(:create) do |order_cancel|
      if order_cancel.order.order_items.empty?
        order_cancel.order.order_items.build(
          product_sales_info: create(:product_sales_info),
          quantity: 1
        )
      end
    end
  end
end
