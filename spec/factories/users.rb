FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "shoki.surface+test#{n}@gmail.com" }
    name { 'Test User' }
    password { 'password' }
    occupation { User.occupations.keys.sample }
  end
end
