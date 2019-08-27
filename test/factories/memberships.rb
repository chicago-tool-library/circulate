FactoryBot.define do
  factory :membership do
    member
    started_on { Time.current.to_date }
    ended_on { started_on + 1.year }
  end
end