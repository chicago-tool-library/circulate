module Admin
  class Verification
    include ActiveModel::Model

    attr_accessor :address_verified
    attr_accessor :id_kind
    attr_accessor :other_id_kind

    validates :address_verified, acceptance: true
    validates :id_kind, presence: true
    validates :other_id_kind, presence: true, if: proc { |v| v.id_kind == :other_id_kind }

    def copy_to(member)
      member.address_verified = address_verified
      member.id_kind = id_kind
      member.other_id_kind = other_id_kind
    end
  end
end
