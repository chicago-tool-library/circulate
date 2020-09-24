class OpenDays
  TIME_SLOTS = [
    OpenStruct.new(day: "Thursday", from: 18, to: 20),
    OpenStruct.new(day: "Saturday", from: 10, to: 16),
  ].freeze

  def self.next_slots(weeks: 2, time_slots: TIME_SLOTS)
    weeks.times.flat_map do |weeks_from_now|
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
    end
  end

  def self.next_slots_for_select(weeks: 2)
    next_slots(weeks: weeks).inject({}) do |dates, date|
      puts date
      dates[date.strftime("%a %b %e")] ||= []
      dates[date.strftime("%a %b %e")] << [
        "#{date.strftime("%l %P")} to #{(date + 1.hour).strftime("%l %P")}",
        date..date + 1.hour,
      ]
    end
    # {
    #   'Thursday' => [
    #     ['from to', 'Mon, 21 Sep 2020..Thu, 24 Sep 2020 23:59:59 UTC +00:00'],
    #     ['from to', 'Mon, 21 Sep 2020..Thu, 24 Sep 2020 23:59:59 UTC +00:00'],
    #     ['from to', 'Mon, 21 Sep 2020..Thu, 24 Sep 2020 23:59:59 UTC +00:00'],
    #   ]
    # }
  end
end
