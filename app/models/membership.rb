class Membership < ApplicationRecord
  belongs_to :member
  scope :active, -> { where("started_on <= ? AND ended_on >= ?", Time.current, Time.current) }
end
