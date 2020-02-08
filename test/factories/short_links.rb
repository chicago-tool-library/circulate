FactoryBot.define do
  factory :short_link do
    url { "http://example.com/#{SecureRandom.uuid}" }
    views_count { 0 }
  end
end
