class Organization < ApplicationRecord
  validates :name, presence: true, uniqueness: {scope: :library_id}
end
