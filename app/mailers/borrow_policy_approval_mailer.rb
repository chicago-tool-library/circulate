class BorrowPolicyApprovalMailer < ApplicationMailer
  before_action :generate_uuid
  after_action :set_uuid_header
  after_action :store_notification

  def approved
    @borrow_policy_approval = params[:borrow_policy_approval]
    @member = @borrow_policy_approval.member
    @borrow_policy = @borrow_policy_approval.borrow_policy
    @library = @member.library
    @subject = "You have been approved to borrow #{@borrow_policy.code} #{@borrow_policy.name} tools"
    mail(to: @member.email, subject: @subject)
  end

  def rejected
    @borrow_policy_approval = params[:borrow_policy_approval]
    @member = @borrow_policy_approval.member
    @borrow_policy = @borrow_policy_approval.borrow_policy
    @library = @member.library
    @subject = "You have not been approved to borrow #{@borrow_policy.code} #{@borrow_policy.name} tools at this time"
    mail(to: @member.email, subject: @subject)
  end

  def revoked
    @borrow_policy_approval = params[:borrow_policy_approval]
    @member = @borrow_policy_approval.member
    @borrow_policy = @borrow_policy_approval.borrow_policy
    @library = @member.library
    @subject = "You may no longer borrow #{@borrow_policy.code} #{@borrow_policy.name} tools"
    mail(to: @member.email, subject: @subject)
  end

  private

  def generate_uuid
    @uuid = SecureRandom.uuid
  end

  def set_uuid_header
    headers["X-SMTPAPI"] = {
      unique_args: {
        uuid: @uuid
      }
    }.to_json
  end

  def store_notification
    Notification.create!(member: @member, uuid: @uuid, action: action_name, address: @member.email, subject: @subject, library: @library)
  end
end
