FactoryBot.define do
  factory :item_pool do
    creator { create(:user) }
    name { "Item Pool" }
  end
end
