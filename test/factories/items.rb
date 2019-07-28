FactoryBot.define do
  factory :item do
    name { "Drill/Driver Kit" }
    status { Item.statuses[:active] }
    before :create, &:assign_number
    borrow_policy
  end
end
