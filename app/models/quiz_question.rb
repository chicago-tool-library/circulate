# A multiple-choice question asked after the policy presentation during
# signup and renewal. Questions are archived rather than deleted so the
# times_chosen counts on their choices keep meaning something.
class QuizQuestion < ApplicationRecord
  belongs_to :library, optional: false
  has_many :choices, -> { order(:position, :id) }, class_name: "QuizChoice", dependent: :destroy, inverse_of: :question

  acts_as_tenant :library

  validates :content, presence: true
  validate :has_a_correct_choice

  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: ->(attrs) { attrs["content"].blank? }

  scope :active, -> { where(archived_at: nil) }
  scope :ordered, -> { order(:position, :id) }

  def archived?
    archived_at.present?
  end

  def correct_choice
    choices.find(&:correct?)
  end

  private

  def has_a_correct_choice
    kept = choices.reject(&:marked_for_destruction?)
    if kept.size < 2
      errors.add(:choices, "must include at least two answers")
    elsif kept.none?(&:correct?)
      errors.add(:choices, "must mark one answer as correct")
    end
  end
end
