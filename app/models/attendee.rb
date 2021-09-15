class Attendee
  include StoreModel::Model

  attribute :email, :string
  attribute :name, :string

  # "needsAction" - The attendee has not responded to the invitation.
  # "declined" - The attendee has declined the invitation.
  # "tentative" - The attendee has tentatively accepted the invitation.
  # "accepted" - The attendee has accepted the invitation.
  enum :status, {
    needsAction: "needsAction",
    declined: "declined",
    tentative: "tentative",
    accepted: "accepted"
  }

  validates :email, :status, presence: true

  def accepted?
    status == "accepted"
  end

  def declined?
    status == "declined"
  end
end
