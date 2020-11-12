FactoryBot.define do
  factory :item_attachment do
    item_id { nil }
    kind { "" }
    other_kind { "MyString" }
  end
end
