class Agreement < ApplicationRecord
  has_many :acceptances, class_name: "AgreementAcceptance", dependent: :destroy

  acts_as_list
  has_rich_text :body

  validates_presence_of :name

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order("position ASC") }
end
