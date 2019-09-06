module Volunteer
  class Event
    attr_reader :id, :start, :finish

    def initialize(id:, start:, finish:, attendees:)
      @id = id
      @start = start
      @finish = finish
      @attendees = attendees
    end

    def slots
      4
    end

    def available_slots
      slots - reserved_slots
    end

    def reserved_slots
      @attendees.size
    end

    def times
      hour_meridian = "%l%P"
      @start.strftime(hour_meridian) + "-" + @finish.strftime(hour_meridian)
    end
  end
end