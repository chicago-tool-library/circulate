# frozen_string_literal: true

class AgreementAcceptance < ApplicationRecord
  belongs_to :member

  validates_acceptance_of :terms
end
