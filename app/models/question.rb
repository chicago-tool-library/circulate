class Question < ApplicationRecord
  belongs_to :library, required: true
  has_many :stems, dependent: :destroy

  acts_as_tenant :library

  validates :name, presence: true, uniqueness: true
end
