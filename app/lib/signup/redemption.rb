module Signup
  class Redemption
    include ActiveModel::Model

    attr_accessor :code
    attr_accessor :gift_membership_id

    validates_each :code do |record, attr, value|
      if value
        gift_membership = GiftMembership.where(code: value).first
        record.gift_membership_id = gift_membership&.id
        if !gift_membership
          record.errors.add(attr, "is not a valid code")
        elsif gift_membership.membership_id.present?
          record.errors.add(attr, "has already been redeemed")
        end
      else
        record.errors.add(attr, "is not a valid code")
      end
    end
  end
end
