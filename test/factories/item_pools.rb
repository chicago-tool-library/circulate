FactoryBot.define do
  factory :item_pool do
    creator { association(:user) }
    sequence(:name) { |n| "Item Pool ##{n}" }
    trait :unnumbered do
      uniquely_numbered { false }
      unnumbered_count { 1 }
    end
  end
end
