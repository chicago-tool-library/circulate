FactoryBot.define do
  factory :note do
    association :creator, factory: :user
    body { "This is a note" }
  end
end
