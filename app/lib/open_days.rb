# frozen_string_literal: true

class OpenDays
  TIME_SLOTS = [
    OpenStruct.new(day: "Thursday", from: 18, to: 20),
    OpenStruct.new(day: "Saturday", from: 10, to: 16)
  ].freeze

  def self.next_slots(weeks: 2, time_slots: TIME_SLOTS)
    weeks.times.flat_map { |weeks_from_now|
      time_slots.flat_map do |slot|
        (slot.from...slot.to).map do |time|
          if time == 12
            Chronic.parse("#{weeks_from_now} week from now #{slot.day} at #{time} pm")
          elsif time > 12
            Chronic.parse("#{weeks_from_now} week from now #{slot.day} at #{time - 12} pm")
          else
            Chronic.parse("#{weeks_from_now} week from now #{slot.day} at #{time} am")
          end
        end
      end
    }.sort
  end

  def self.next_slots_for_select(weeks: 2, time_slots: TIME_SLOTS)
    next_slots(weeks:, time_slots:).each_with_object({}) do |date, memo|
      key = date.strftime("%A, %B %-d, %Y")
      memo[key] ||= []
      memo[key] << [
        "#{date.strftime("%-l %P")} to #{(date + 1.hour).strftime("%-l %P")}",
        date..date + 1.hour
      ]
    end
  end
end
