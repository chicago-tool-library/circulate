FactoryBot.define do
  factory :membership do
    library { Library.first || create(:library) }
    member
    started_at { 1.month.ago }
    after(:build) { |m| m.ended_at = m.started_at + 364.days if m.started_at }

    factory :pending_membership do
      started_at { nil }
      ended_at { nil }
    end
  end
end
