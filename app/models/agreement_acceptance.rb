class AgreementAcceptance < ApplicationRecord
  belongs_to :member

  validates :terms, acceptance: true
end
