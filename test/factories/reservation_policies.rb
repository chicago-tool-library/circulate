FactoryBot.define do
  factory :reservation_policy do
    library { Library.first || association(:library) }
    sequence(:name) { |n| "Policy ##{n}" }
    default { false }
    maximum_duration { 21 }
    minimum_start_distance { 2 }
    maximum_start_distance { 90 }
  end
end
