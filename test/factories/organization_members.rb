FactoryBot.define do
  factory :organization_member do
    sequence(:full_name) { |n| "Ida B. Wells #{n}" }
    organization { association(:organization) }
    user { association(:user) }
    role { OrganizationMember.roles["member"] }

    trait :member do
      role { OrganizationMember.roles["member"] }
    end

    trait :admin do
      role { OrganizationMember.roles["admin"] }
    end
  end
end
