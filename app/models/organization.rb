class Organization < ApplicationRecord
  acts_as_tenant :library

  validates :name, presence: true, uniqueness: {scope: :library_id}
end
