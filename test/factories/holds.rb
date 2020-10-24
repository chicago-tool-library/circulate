FactoryBot.define do
  factory :hold do
    member
    item
    creator { create(:user) }
  end
end
