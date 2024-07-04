class Stem < ApplicationRecord
  enum answer_type: {
    "integer" => "integer",
    "text" => "text"
  }

  belongs_to :question, required: true
  has_many :answers, dependent: :destroy

  validates :content, presence: true
  validates :answer_type, presence: true
  validates :version, presence: true, uniqueness: {scope: :question_id}

  before_validation :assign_version

  private

  def assign_version
    return if version? || question.blank?
    self.version = (question.stems.pluck(:version).max.presence || 0) + 1
  end
end
