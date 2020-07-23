FactoryBot.define do
  factory :event do
    calendar_id { "MyString" }
    google_event_id { "MyString" }
    start { "2020-07-22 12:51:56" }
    finish { "2020-07-22 12:51:56" }
    summary { "MyString" }
    description { "MyString" }
    attendees { "" }
  end
end
