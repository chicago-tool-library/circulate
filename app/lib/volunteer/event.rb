module Volunteer
  class Event
    attr_reader :id, :summary, :description, :start, :finish, :attendees

    def initialize(id:, summary:, start:, finish:, attendees:, description: nil)
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
      format = "%l:%M%P"
      "#{start.strftime(format).strip} - #{finish.strftime(format).strip}".gsub(/:00/, "").strip
    end

    def attended_by?(email)
      @attendees.any? { |a| a.email == email }
    end
  end
end
