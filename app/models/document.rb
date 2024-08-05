class Document < ApplicationRecord
  has_rich_text :body

  validates :name, :summary, presence: true

  scope :coded, ->(code) { where(code: code) }

  acts_as_tenant :library

  def to_param
    code
  end

  def self.borrow_policy
    coded("borrow_policy").first!
  end

  def self.agreement
    coded("agreement").first!
  end
end
