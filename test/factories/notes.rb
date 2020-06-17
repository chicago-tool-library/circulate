FactoryBot.define do
  factory :note do
    association :creator, factory: :user
  end
end
