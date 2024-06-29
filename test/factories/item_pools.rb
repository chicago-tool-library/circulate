FactoryBot.define do
  factory :item_pool do
    creator { association(:user) }
    sequence(:name) { |n| "Item Pool ##{n}" }
  end
end
