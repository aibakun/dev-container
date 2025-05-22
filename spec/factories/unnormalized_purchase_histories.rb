FactoryBot.define do
  factory :unnormalized_purchase_history do
    user_name { 'testuser' }
    user_email { 'shoki.surface@gmail.com' }
    product_name { 'Premium Coffee' }
    product_price { 1500 }
    quantity { 2 }
    category_name { 'Beverages' }
    purchase_date { Time.current }

    trait :with_low_price do
      product_price { 500 }
    end

    trait :with_high_quantity do
      product_name { 'Bulk Paper' }
      quantity { 20 }
    end

    trait :old_purchase do
      purchase_date { 1.year.ago }
    end

    trait :invalid_email do
      user_email { 'invalid-email' }
    end

    trait :zero_price do
      product_price { 0 }
    end

    trait :negative_quantity do
      quantity { -1 }
    end
  end
end
