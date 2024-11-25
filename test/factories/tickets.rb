FactoryBot.define do
  factory :ticket do
    library { Library.first || create(:library) }
    sequence(:title) { |n| "Makes a terrible noise #{n}" }
    item
    status { "assess" }
    association :creator, factory: :user
  end

  Ticket.statuses.values.each do |value|
    trait value do
      status { value }
    end
  end
end
