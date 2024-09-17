class Organization < ApplicationRecord
  acts_as_tenant :library

  validates :name, presence: true, uniqueness: {scope: :library_id}
  validates :website, uniqueness: {scope: :library_id}

  has_many :organization_members, dependent: :destroy
end
