FactoryBot.define do
  factory :reservation do
    name { "A reservation" }
    started_at { Time.current.at_beginning_of_day }
    ended_at { 1.week.since.at_beginning_of_day }
  end
end
