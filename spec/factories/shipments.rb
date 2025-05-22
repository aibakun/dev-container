FactoryBot.define do
  factory :shipment do
    association :order
    tracking_number { SecureRandom.hex(8).upcase }
    status { :preparing }
  end
end
