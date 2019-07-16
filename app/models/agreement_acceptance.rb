class DocumentAcceptance < ApplicationRecord
  belongs_to :document
  belongs_to :member

  validates_acceptance_of :terms
end
