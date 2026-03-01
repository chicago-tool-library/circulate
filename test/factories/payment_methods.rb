FactoryBot.define do
  factory :payment_method do
    stripe_id { SecureRandom.hex(10) }
    display_brand { %w[visa mastercard discover].sample }
    last_four { rand(1000..9999).to_s }
    expire_month { rand(1..12) }
    expire_year { 5.times.map { |n| n.years.from_now.year }.sample }
    association :user
  end
end
