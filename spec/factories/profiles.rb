FactoryBot.define do
  factory :profile do
    biography { 'This is a test biography' }
    association :user
  end
end
