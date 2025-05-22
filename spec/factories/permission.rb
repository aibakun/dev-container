FactoryBot.define do
  factory :permission do
    user
    sequence(:controller) { 'users' }
    sequence(:action) { 'index' }
  end
end
