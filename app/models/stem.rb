class Stem < ApplicationRecord
  enum answer_type: {
    "integer" => "integer",
    "text" => "text"
  }

  belongs_to :question, required: true
  has_many :answers, dependent: :destroy

  validates :content, presence: true
  validates :answer_type, presence: true
end
