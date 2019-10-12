FactoryBot.define do
  factory :user do
    email
    password { "password" }
  end
end
