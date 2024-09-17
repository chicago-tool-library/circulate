class OrganizationMember < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  validates :full_name, presence: true
end
