FactoryBot.define do
  factory :quiz_question do
    library { Library.first || create(:library) }
    sequence(:content) { |n| "Question #{n}?" }
    explanation { "Here's why." }
    sequence(:position)

    after(:build) do |question|
      if question.choices.empty?
        question.choices.build(content: "Right", correct: true, position: 1)
        question.choices.build(content: "Wrong", correct: false, position: 2)
      end
    end
  end
end
