FactoryBot.define do
  factory :user do
    library { Library.first || association(:library) }

    sequence(:email) do |n|
      "person#{n}@example.com"
    end
    password { "password" }
    confirmation_sent_at { Time.current }
    confirmed_at { Time.current }
    member { association(:member, email:) }

    trait :unconfirmed do
      confirmation_sent_at { nil }
      confirmed_at { nil }
    end

    factory :member_user do
      role { "member" }
    end

    factory :staff_user do
      role { "staff" }
    end

    factory :admin_user do
      role { "admin" }
    end

    factory :super_admin_user do
      role { "super_admin" }
    end
  end
end
