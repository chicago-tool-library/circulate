class Document < ApplicationRecord
  has_many :acceptances, class_name: "DocumentAcceptance", dependent: :destroy

  has_rich_text :body

  validates_presence_of :name, :summary
end
