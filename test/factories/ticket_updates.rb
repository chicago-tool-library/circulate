FactoryBot.define do
  factory :ticket_update do
    ticket { association(:ticket) }
    sequence(:body) { |n| "This ticket update ##{n}" }
    creator { association(:user) }
  end
end
