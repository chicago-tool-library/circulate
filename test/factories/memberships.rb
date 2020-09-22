FactoryBot.define do
  factory :membership do
    library { Library.first || create(:library) }
    member
    started_on { Time.current - 1.month }
    ended_on { started_on + 11.months }
  end
end
