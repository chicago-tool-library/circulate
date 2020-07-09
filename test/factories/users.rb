FactoryBot.define do
  factory :user do
    email
    password { "password" }

    factory :admin_user do
      role { "admin" }
    end
  end
end
