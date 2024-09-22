FactoryBot.define do
  factory :organization_member do
    sequence(:full_name) { |n| "Ida B. Wells #{n}" }
    organization { association(:organization) }
    user { association(:user) }
  end
end
