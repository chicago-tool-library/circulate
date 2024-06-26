FactoryBot.define do
  factory :user do
    library { Library.first || create(:library) }

    email
    password { "password" }

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
