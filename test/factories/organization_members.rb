FactoryBot.define do
  factory :organization_member do
    full_name { "MyText" }
    organization { association(:organization) }
    user { association(:user) }
  end
end
