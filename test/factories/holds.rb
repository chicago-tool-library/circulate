# frozen_string_literal: true

FactoryBot.define do
  factory :hold do
    library { Library.first || create(:library) }
    member
    item
    creator { create(:user) }
    factory :expired_hold do
      started_at { 3.weeks.ago }
      expires_at { 2.weeks.ago }
    end
    factory :ended_hold do
      ended_at { Time.current }
    end
    factory :started_hold do
      after(:build) { |hold| hold.start! }
    end
  end
end
