FactoryBot.define do
  factory :library do
    name { "Library of Alexandria" }
    sequence :hostname do |n|
      "alexandria#{n}.example.com"
    end
    member_postal_code_pattern { ".*"}
    city { "Alexandria" }
    email { "team@alexandria.example.com" }
    address do
      <<~ADDRESS.strip
        Library of Alexandria
        123 Some Street
        Alexandria
        alexandria.example.com
      ADDRESS
    end
  end
end
