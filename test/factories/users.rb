FactoryBot.define do
  factory :user do
    library { Library.first || create(:library) }

    email
    password { "password" }

    factory :admin_user do
      role { "admin" }
    end
  end
end
