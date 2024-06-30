FactoryBot.define do
  factory :organization_member do
    full_name { "MyText" }
    organization { nil }
    user { nil }
  end
end
