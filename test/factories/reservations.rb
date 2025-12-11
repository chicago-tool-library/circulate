FactoryBot.define do
  factory :reservation do
    sequence(:name) { |n| "A reservation ##{n}" }
    started_at { Time.current.at_beginning_of_day }
    ended_at { 1.week.since.at_beginning_of_day }
    library { Library.first || association(:library) }
    member

    after(:build) { |reservation| reservation.send(:restore_manager) }

    trait :pending do
      status { "pending" }
      notes { nil }
    end

    trait :requested do
      status { "requested" }
      notes { nil }
      pickup_event { association(:event) }
    end

    trait :approved do
      status { "approved" }
      notes { "This reservation has been approved! :)" }
      pickup_event { association(:event) }
    end

    trait :rejected do
      status { "rejected" }
      notes { "This reservation has been rejected :(" }
      pickup_event { association(:event) }
    end

    trait :obsolete do
      status { "obsolete" }
      pickup_event { association(:event) }
    end

    trait :building do
      status { "building" }
      notes { "This reservation is building" }
      pickup_event { association(:event) }
    end

    trait :ready do
      status { "ready" }
      notes { "This reservation is ready" }
      pickup_event { association(:event) }
    end

    trait :borrowed do
      status { "borrowed" }
      notes { "This reservation is borrowed" }
      pickup_event { association(:event) }
    end

    trait :returned do
      status { "returned" }
      notes { "This reservation is returned" }
      pickup_event { association(:event) }
    end

    trait :unresolved do
      status { "unresolved" }
      notes { "This reservation is unresolved" }
      pickup_event { association(:event) }
    end

    trait :cancelled do
      status { "cancelled" }
      notes { "This reservation is cancelled" }
      pickup_event { association(:event) }
    end
  end
end
