FactoryBot.define do
  factory :hold_request do
    library { Library.first || create(:library) }
  end
end
