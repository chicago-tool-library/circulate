FactoryBot.define do
  factory :reservation do
    sequence(:name) { |n| "A reservation ##{n}" }
    library { Library.first || association(:library) }
    member

    after(:build) do |reservation|
      # It's really common in tests to just specify started_at and ended_at,
      # so if those are set but the events aren't, build reasonable events.
      if reservation.started_at? && reservation.pickup_event.blank?
        reservation.pickup_event = build(:event, start: reservation.started_at + 10.hours)
      end
      if reservation.ended_at? && reservation.dropoff_event.blank?
        reservation.dropoff_event = build(:event, start: reservation.ended_at - 10.hours)
      end

      # Fill in default events if needed
      ten_am_today = Time.current.beginning_of_day + 10.hours
      reservation.pickup_event ||= build(:event, start: ten_am_today)
      one_week_after_pickup = (reservation.pickup_event.start || ten_am_today) + 7.days
      reservation.dropoff_event ||= build(:event, start: one_week_after_pickup)

      reservation.send(:restore_manager)
    end

    trait :pending do
      status { "pending" }
      notes { nil }
    end

    trait :requested do
      status { "requested" }
      notes { nil }
    end

    trait :approved do
      status { "approved" }
      notes { "This reservation has been approved! :)" }
    end

    trait :rejected do
      status { "rejected" }
      notes { "This reservation has been rejected :(" }
    end

    trait :obsolete do
      status { "obsolete" }
    end

    trait :building do
      status { "building" }
      notes { "This reservation is building" }
    end

    trait :ready do
      status { "ready" }
      notes { "This reservation is ready" }
    end

    trait :borrowed do
      status { "borrowed" }
      notes { "This reservation is borrowed" }
    end

    trait :returned do
      status { "returned" }
      notes { "This reservation is returned" }
    end

    trait :unresolved do
      status { "unresolved" }
      notes { "This reservation is unresolved" }
    end

    trait :cancelled do
      status { "cancelled" }
      notes { "This reservation is cancelled" }
    end
  end
end
