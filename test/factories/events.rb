FactoryBot.define do
  sequence :calendar_event_id do |n|
    "CALEVENTID#{n}"
  end

  factory :event do
    library { Library.first || create(:library) }
    calendar_id { "calid1234" }
    calendar_event_id
    start { "2020-07-22 12:51:56" }
    finish { "2020-07-22 12:51:56" }
    summary { "An event" }
    description { "More information about the event" }
  end

  factory :volunteer_shift_event, class: Event do
    library { Library.first || create(:library) }
    calendar_id { "volcalid" }
    calendar_event_id
    start { "2020-07-22 12:51:56" }
    finish { "2020-07-22 12:51:56" }
    summary { "Librarian" }
    description { "More information about the event" }
  end
end
