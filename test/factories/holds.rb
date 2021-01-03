FactoryBot.define do
  factory :hold do
    member
    item
    creator { create(:user) }
    factory :expired_hold do
      started_at { 3.weeks.ago }
    end
    factory :ended_hold do
      ended_at { Time.current }
    end
    factory :started_hold do
      started_at { Time.current }
    end
  end
end
