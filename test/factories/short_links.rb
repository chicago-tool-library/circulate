# frozen_string_literal: true

FactoryBot.define do
  factory :short_link do
    library { Library.first || create(:library) }
    url { "http://example.com/#{SecureRandom.uuid}" }
    views_count { 0 }
  end
end
