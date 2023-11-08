class MemberTexter < BaseTexter
  include ActionView::Helpers::TextHelper

  attr_reader :member

  def initialize(member)
    @member = member
  end

  def overdue_notice(summaries)
    return unless member.reminders_via_text?

    message = <<~EOM
      Chicago Tool Library Reminder: You have #{pluralize(summaries.length, "overdue item")}! Please schedule a return appointment at #{account_member_url}
    EOM
    result = text(to: @member.canonical_phone_number, body: message)
    store_notification("overdue_notice", message, result)
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
