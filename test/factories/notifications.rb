FactoryBot.define do
  factory :notification do
    member
    address { member.email }
    action { "mailer_action" }
    uuid { SecureRandom.uuid }
    status { "pending" }
    subject { "a subject" }
  end
end
