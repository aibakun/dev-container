FactoryBot.define do
  factory :order do
    user
    order_date { Time.current }

    after(:build) do |order|
      order.order_items.build(
        product_sales_info: create(:product_sales_info),
        quantity: 1
      )
    end

    trait :with_items do
      after(:create) do |order|
        create(:order_item, order: order)
      end
    end

    trait :cancelled do
      after(:create) do |order|
        create(:order_cancel, order: order)
      end
    end
  end
end
