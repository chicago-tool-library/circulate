# frozen_string_literal: true

FactoryBot.define do
  factory :item_attachment do
    kind { "manual" }
    other_kind { "MyString" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("test", "fixtures", "files", "tool-image.jpg"), "image/jpg") }
  end
end
