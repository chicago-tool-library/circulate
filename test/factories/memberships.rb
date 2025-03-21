FactoryBot.define do
  factory :membership do
    library { Library.first || create(:library) }
    member { association(:member, :with_user) }
    started_at { 1.month.ago }
    after(:build) do |m|
      if m.started_at && !m.ended_at?
        m.ended_at = m.started_at + 364.days
      end
    end

    factory :pending_membership do
      started_at { nil }
      ended_at { nil }
    end
  end
end
