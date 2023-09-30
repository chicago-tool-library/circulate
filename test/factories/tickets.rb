# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    library { Library.first || create(:library) }
    title { "Makes a terrible noise" }
    item
    status { "assess" }
    association :creator, factory: :user
  end
end
