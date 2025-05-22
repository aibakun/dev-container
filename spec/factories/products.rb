FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    category { :food }
  end

  factory :product_sales_info do
    product
    price { rand(1000..10_000) }
    effective_from { Time.current }
    discontinued { false }

    trait :discontinued do
      discontinued { true }
    end
  end
end
