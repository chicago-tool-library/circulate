FactoryBot.define do
  factory :user do
    email
    password { "password" }

    factory :admin_user do
      role { "admin" }
    end

    factory :super_admin_user do
      role { "super_admin" }
    end
  end
end
