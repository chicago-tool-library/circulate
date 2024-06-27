class Organization < ApplicationRecord
  acts_as_tenant :library

  validates :name, presence: true, uniqueness: true
end
