module Volunteer
  class Event
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def title
      "Event Title"
    end

    def slots
      4
    end

    def available_slots
      @available_slots ||= (slots * rand).floor
    end

    def reserved_slots
      slots - available_slots
    end

    def times
      "10am-3pm"
    end
  end
end