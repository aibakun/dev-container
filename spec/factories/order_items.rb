FactoryBot.define do
  factory :order_item do
    order
    product_sales_info
    quantity { 1 }
  end
end
