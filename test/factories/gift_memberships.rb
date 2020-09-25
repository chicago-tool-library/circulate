FactoryBot.define do
  factory :gift_membership do
    library { Library.first || create(:library) }
    sequence :purchaser_email do |n|
      "purchaser#{n}@example.com"
    end
    purchaser_name { "Gift Giver" }
    amount_cents { 123 }
  end
end
