FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :member do
    full_name { "Ida B. Wells" }
    email
    phone_number { "3121234567" }
    postal_code { "60609" }

    factory :complete_member do
      preferred_name { "Ida" }
      pronoun { 2 }

      factory :active_member do
        id_kind { 1 }
        address_verified { true }
        status { "active" }
        after(:create) do |member, evaluator|
          create_list(:membership, 1, member: member)
        end
      end
    end
  end
end
