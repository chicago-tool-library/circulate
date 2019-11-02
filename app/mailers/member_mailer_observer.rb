class MemberMailerObserver
  def self.delivered_email(message)
    smtpapi_json = message["X-SMTPAPI"].value
    smtpapi_args = JSON.parse(smtpapi_json)
    uuid = smtpapi_args.dig("unique_args", "uuid")
    Notification.where(uuid: uuid).update(status: "sent")
  end
end