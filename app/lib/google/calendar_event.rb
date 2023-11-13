module Google
  class CalendarEvent
    attr_reader :id, :summary, :description, :start, :finish, :attendees, :calendar_id

    def initialize(id:, summary:, start:, finish:, attendees:, calendar_id:, status:, description: nil)
      @id = id
      @calendar_id = calendar_id
      @summary = summary
      @description = description
      @start = start
      @finish = finish
      @status = status # needsAction, confirmed, tentative, or cancelled
      @attendees = attendees
    end

    def accepted_attendees_count
      @attendees.count { |a| a.accepted? }
    end

    def times
      format = "%l:%M%P"
      "#{start.strftime(format).strip} - #{finish.strftime(format).strip}".gsub(":00", "").strip
    end

    def date
      @start.to_date
    end

    def attended_by?(email)
      @attendees.any? { |a| a.email == email }
    end

    def cancelled?
      @status == "cancelled"
    end
  end
end
