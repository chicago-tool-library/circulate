FactoryBot.define do
  factory :hold do
    library { Library.first || create(:library) }
    member
    item
  end
end
