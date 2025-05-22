FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag#{n}" }

    trait :with_posts do
      transient do
        posts_count { 3 }
      end

      after(:create) do |tag, evaluator|
        create_list(:post, evaluator.posts_count, tags: [tag])
      end
    end
  end
end
