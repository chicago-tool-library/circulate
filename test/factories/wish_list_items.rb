FactoryBot.define do
  factory :wish_list_item do
    item { association(:item) }
    member { association(:member) }
  end
end
