FactoryBot.define do
  factory :item_pool do
    creator { association(:user) }
    sequence(:name) { |n| "Item Pool ##{n}" }
    trait :unnumbered do
      uniquely_numbered { false }
      unnumbered_count { 1 }
    end

    trait :with_image do
      image { Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/tool-image.jpg"), "image/jpeg") }
    end
  end
end
