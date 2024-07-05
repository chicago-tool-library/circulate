class Stem < ApplicationRecord
  module AnswerTypes
    INTEGER = "integer"
    TEXT = "text"

    ALL = [TEXT, INTEGER]
  end

  enum answer_type: {
    AnswerTypes::INTEGER => AnswerTypes::INTEGER,
    AnswerTypes::TEXT => AnswerTypes::TEXT
  }

  belongs_to :question, required: true
  has_many :answers, dependent: :destroy

  validates :content, presence: true
  validates :answer_type, presence: true
end
