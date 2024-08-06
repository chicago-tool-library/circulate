FactoryBot.define do
  sequence :number, 1000

  factory :item do
    library { Library.first || create(:library) }
    number
    name { "Item ##{number}" }
    status { Item.statuses[:active] }
    before :create, &:assign_number
    borrow_policy
    checkout_notice { "Example Notice: Make sure all five removable pieces are returned." }

    factory :complete_item do
      brand { "Dewalt" }
      size { "1/4" }
      strength { "12v" }
      serial { "abcdefg" }
      power_source { Item.power_sources[:electric_battery] }
    end

    factory :uncounted_item do
      quantity { 10 }
      borrow_policy factory: :unnumbered_borrow_policy
    end

    factory :consumable_item do
      quantity { 10 }
      borrow_policy factory: :consumable_borrow_policy
    end

    trait :with_image do
      image { Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/tool-image.jpg"), "image/jpeg") }
    end

    trait :active do
      status { Item.statuses[:active] }
    end

    trait :maintenance do
      status { Item.statuses[:maintenance] }
    end

    trait :uniquely_numbered do
      borrow_policy { association(:borrow_policy, uniquely_numbered: true) }
    end

    trait :unnumbered do
      borrow_policy { association(:unnumbered_borrow_policy) }
    end

    trait :available do
      checked_out_exclusive_loan { nil }
    end

    trait :unavailable do
      checked_out_exclusive_loan { association(:loan, :exclusive, :checked_out) }
    end
  end
end
