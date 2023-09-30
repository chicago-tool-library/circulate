# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    library { Library.first || create(:library) }

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
