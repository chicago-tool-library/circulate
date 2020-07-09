module Volunteer
  class Event
    attr_reader :id, :summary, :description, :start, :finish, :attendees

    def initialize(id:, summary:, description: nil, start:, finish:, attendees:)
      @id = id
      @summary = summary
      @description = description
      @start = start
      @finish = finish
      @attendees = attendees
    end

    def accepted_attendees_count
      @attendees.count { |a| a.accepted? }
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
