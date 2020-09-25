FactoryBot.define do
  factory :document do
    library { Library.first || create(:library) }
    sequence :name do |n|
      "Document #{n}"
    end
    body { "Body for #{name}" }
    summary { "Summary for #{name}" }
    code { name.underscore }
  end
end
