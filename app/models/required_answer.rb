class RequiredAnswer < Answer
  validates :value, presence: true
end
