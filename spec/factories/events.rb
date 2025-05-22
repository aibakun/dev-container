FactoryBot.define do
  factory :event do
    association :user
    sequence(:title) { |n| "Event #{n}" }
    description { 'Event description' }
    location { 'Event location' }
    start_at { 1.day.from_now }
    end_at { 2.days.from_now }

    trait :past do
      start_at { 2.days.ago }
      end_at { 1.day.ago }
    end

    trait :future do
      start_at { 1.day.from_now }
      end_at { 2.days.from_now }
    end
  end
end
