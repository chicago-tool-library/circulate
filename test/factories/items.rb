FactoryBot.define do
  sequence :number, 1000

  factory :item do
    number
    name { "Drill/Driver Kit" }
    status { Item.statuses[:active] }
    before :create, &:assign_number
    borrow_policy
  end
end
