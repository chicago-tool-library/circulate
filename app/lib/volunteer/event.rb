module Volunteer
  class Event
    attr_reader :id, :start, :finish, :attendees

    def initialize(id:, start:, finish:, attendees:)
      @id = id
      @start = start
      @finish = finish
      @attendees = attendees
    end

    def accepted_attendees_count
      @attendees.select { |a| a.accepted? }.size
    end

    def times
      hour_meridian = "%l%P"
      @start.strftime(hour_meridian) + " - " + @finish.strftime(hour_meridian).strip
    end

    def attended_by?(email)
      @attendees.any? { |a| a.email == email }
    end
  end
end