class AgreementAcceptance < ApplicationRecord
  belongs_to :agreement
  belongs_to :member

  validates_acceptance_of :terms
end
