FactoryBot.define do
  factory :post do
    title { 'This is a test title' }
    content { 'This is a test content' }
    published_at { nil }
    archived { false }
    association :user

    trait :draft do
      published_at { nil }
      archived { false }
    end

    trait :published do
      published_at { Time.current }
      archived { false }
    end

    trait :archived do
      published_at { 1.day.ago }
      archived { true }
    end

    trait :scheduled do
      published_at { 1.day.from_now }
      archived { false }
    end

    trait :previously_published do
      published_at { 1.day.ago }
      archived { false }
    end
  end
end
