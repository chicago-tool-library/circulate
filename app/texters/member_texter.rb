class MemberTexter < BaseTexter
  include ActionView::Helpers::TextHelper

  attr_reader :member

  def initialize(member)
    @member = member
  end

  def welcome_info
    message = <<~EOM.chomp
      Hello! You will get Chicago Tool Library reminders from this number

      You can turn off text reminders at #{edit_account_member_url}
    EOM
    result = text(to: @member.canonical_phone_number, body: message)
    store_notification("welcome_info", message, result)
    result
  end

  def overdue_notice(summaries)
    return unless member.reminders_via_text?

    message = <<~EOM.chomp
      Chicago Tool Library Reminder: You have #{pluralize(summaries.length, "overdue item")}! Please schedule a return appointment at #{new_account_appointment_url}
    EOM
    result = text(to: @member.canonical_phone_number, body: message)
    store_notification("overdue_notice", message, result)
    result
  end

  def hold_available(hold)
    return unless member.reminders_via_text?

    message = <<~EOM.chomp
      Chicago Tool Library Reminder: Your hold for #{hold.item.complete_number} is available! Schedule a pick-up at #{new_account_appointment_url}
    EOM
    result = text(to: @member.canonical_phone_number, body: message)
    store_notification("hold_available", message, result)
    result
  end

  def return_reminder(summaries)
    return unless member.reminders_via_text?

    message = <<~EOM.chomp
      Chicago Tool Library Reminder: You have #{pluralize(summaries.length, "item")} due tomorrow. Review your loans at #{account_loans_url}
    EOM
    result = text(to: @member.canonical_phone_number, body: message)
    store_notification("return_reminder", message, result)
    result
  end

  def store_notification(action_name, message, result)
    Notification.create!(
      member: member,
      address: member.canonical_phone_number,
      subject: message,
      uuid: result.sid,
      action: action_name,
      status: result.status,
      library: member.library
    )
  end
end
