class QuizChoice < ApplicationRecord
  belongs_to :question, class_name: "QuizQuestion", foreign_key: :quiz_question_id, inverse_of: :choices, optional: false

  validates :content, presence: true
end
