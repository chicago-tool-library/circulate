class Document < ApplicationRecord
  has_rich_text :body

  validates :name, :summary, presence: true

  enum :code, {
    agreement: "agreement",
    code_of_conduct: "code_of_conduct",
    borrow_policy: "borrow_policy"
  }, validate: true

  acts_as_tenant :library

  def to_param
    code
  end
end
