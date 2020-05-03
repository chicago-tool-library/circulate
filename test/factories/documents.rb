FactoryBot.define do
  factory :document do
    sequence :name do |n|
      "Document #{n}"
    end
    body { "Body for #{name}" }
    summary { "Summary for #{name}" }
    code { name.underscore }
  end
end
