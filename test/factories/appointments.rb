FactoryBot.define do
  factory :appointment do
    starts_at { "2020-09-23 11:14:27" }
    ends_at { "2020-09-23 12:14:27" }
    comment { "My Comment" }
    member { association(:member, :with_user) }

    factory :appointment_with_holds do
      holds { [association(:hold, creator: member.user)] }
    end
  end
end
