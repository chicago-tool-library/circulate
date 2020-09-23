FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :member do
    library { Library.first || create(:library) }

    full_name { "Ida B. Wells" }
    email
    phone_number { "3121234567" }
    postal_code { "60609" }
    address1 { "1 N. Michigan Ave" }

    factory :complete_member do
      preferred_name { "Ida" }
      pronouns { ["she/her"] }
      address1 { "apt 3" }

      factory :verified_member do
        id_kind { 1 }
        address_verified { true }
        status { "verified" }

        factory :verified_member_with_membership do
          after(:create) do |member, evaluator|
            create_list(:membership, 1, member: member)
          end
        end
      end
    end
  end
end
