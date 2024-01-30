class Notification < ApplicationRecord
  belongs_to :member, required: false

  validates :address, presence: true
  validates :action, presence: true
  validates :uuid, presence: true

  acts_as_tenant :library
end
