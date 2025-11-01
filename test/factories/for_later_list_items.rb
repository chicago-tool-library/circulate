FactoryBot.define do
  factory :for_later_list_item do
    item { association(:item) }
    member { association(:member) }
  end
end
