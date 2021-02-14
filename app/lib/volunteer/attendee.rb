module Volunteer
  class Attendee
    attr_reader :email, :name, :status

    def initialize(email:, name:, status: "accepted")
      @email = email
      @name = name
      @status = status
    end

    def accepted?
      @status == "accepted"
    end

    def declined?
      @status == "declined"
    end
  end
end
