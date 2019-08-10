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
      id_kind { 1 }
      address_verified { true }
    end
  end
end