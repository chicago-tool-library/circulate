# frozen_string_literal: true

FactoryBot.define do
  factory :library_update do
    title { "for internal use" }
    body { "this week at the library" }
    published { true }
  end
end
