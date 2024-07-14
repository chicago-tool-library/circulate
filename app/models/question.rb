class Question < ApplicationRecord
  belongs_to :library, required: true
  has_many :stems, dependent: :destroy
  has_one :stem, -> { order(created_at: :desc) }
  has_many :answers, through: :stems

  acts_as_tenant :library

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :stems, allow_destroy: false
end
