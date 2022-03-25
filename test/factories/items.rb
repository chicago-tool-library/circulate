FactoryBot.define do
  sequence :number, 1000

  factory :item do
    library { Library.first || create(:library) }
    number
    name { "Item ##{number}" }
    status { Item.statuses[:active] }
    before :create, &:assign_number
    borrow_policy

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
      image { Rack::Test::UploadedFile.new(Rails.root.join("test", "fixtures", "files", "tool-image.jpg"), "image/jpg") }
    end
  end
end
