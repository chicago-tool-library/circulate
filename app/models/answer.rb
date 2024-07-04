class Answer < ApplicationRecord
  belongs_to :stem, required: true
  belongs_to :reservation, required: true

  validates :result, presence: true
  validates :reservation_id, uniqueness: {scope: :stem_id}

  def value
    return if stem.blank? || result.blank?

    result[stem.answer_type]
  end

  def value=(value)
    if stem
      self.result = {stem.answer_type => value}
    else
      raise ArgumentError, "unable to set value without a stem"
    end
  end
end
