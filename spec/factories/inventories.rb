FactoryBot.define do
  factory :inventory do
    association :product
    quantity { 100 }
  end
end
