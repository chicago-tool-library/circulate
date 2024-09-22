class Answer < ApplicationRecord
  belongs_to :stem, optional: false
  belongs_to :reservation, optional: false

  validates :result, presence: true
  validates :reservation_id, uniqueness: {scope: :stem_id}

  def value
    return if stem.blank? || result.blank?

    result[stem.answer_type]
  end

  def value=(value)
    if stem
      self.result = {stem.answer_type => coerce_value_type(value)}
    else
      raise ArgumentError, "unable to set value without a stem"
    end
  end

  private

  def coerce_value_type(suspect)
    return if suspect.nil?
    case stem.answer_type
    when Stem::AnswerTypes::INTEGER
      suspect.present? ? suspect.to_i : nil
    when Stem::AnswerTypes::TEXT
      suspect.to_s
    end
  end
end
