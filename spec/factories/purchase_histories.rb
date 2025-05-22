FactoryBot.define do
  factory :purchase_history do
    association :user
    sequence(:name) { |n| "PurchaseHistory #{n}" }
    purchase_date { 1.day.ago }
    price { 1000 }
  end
end
