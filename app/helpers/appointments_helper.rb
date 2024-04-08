module AppointmentsHelper
  def format_appointment_times(start, stop)
    date_format = "%l:%M%P"
    "#{start.strftime(date_format).strip} - #{stop.strftime(date_format).strip}"
  end

  def appointment_time(appointment)
    format_appointment_times(appointment.starts_at, appointment.ends_at)
  end

  # These sort keys are designed to group all appointments for a given member together,
  # positioned based on that member's earliest appointment for the day. We do this by
  # determining the time of a member's first appointment on a given day and using that
  # as a prefix on the sort key.
  #
  # The sort key consists of the following values joined together:
  #
  # - start time of a member's first appointment of the day
  # - the member's preferred name
  # - the start time of the appointment
  # - the creation date of the appointment
  #
  # The actual sort keys include the appointment creation time to ensure a stable sort order
  # in the case of members with the same name and time, but for simpicity it is not shown in
  # the examples below.
  #
  # Given the following members and appointments:
  #
  # start_time | member_name | sort_key
  # ===========|=============|==========
  # 10am       | aaa         | 10-aaa-10
  # 10am       | bbb         | 10-bbb-10
  # 10am       | ccc         | 10-ccc-10
  # 12am       | bbb         | 10-bbb-12
  # 12am       | eee         | 12-eee-12
  # 12am       | ddd         | 12-ddd-12
  #
  # The appointments will be displayed in the following order:
  #
  # 10-aaa-10
  # 10-bbb-10
  # 10-bbb-12
  # 10-ccc-10
  # 12-ddd-12
  # 12-eee-12
  #
  def appointment_sort_key(appointment)
    first_start_time_for_member = appointment.same_day_and_member.first.starts_at.hour

    start_time = appointment.starts_at.hour
    member_name = preferred_or_default_name(appointment.member)
    created_at = appointment.created_at.to_i
    "#{first_start_time_for_member}-#{member_name}-#{start_time}-#{created_at}"
  end
end
