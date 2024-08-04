FactoryBot.define do
  factory :item_attachment do
    kind { "manual" }
    other_kind { "MyString" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/tool-image.jpg"), "image/jpeg") }
  end
end
