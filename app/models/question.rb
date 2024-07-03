class Question < ApplicationRecord
  belongs_to :library, required: true

  acts_as_tenant :library

  validates :name, presence: true, uniqueness: true
end
