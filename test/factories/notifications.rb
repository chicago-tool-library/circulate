# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    library { Library.first || create(:library) }
    member
    address { member.email }
    action { "mailer_action" }
    uuid { SecureRandom.uuid }
    status { "pending" }
    subject { "a subject" }
  end
end
