class Document < ApplicationRecord
  has_rich_text :body

  validates_presence_of :name, :summary

  scope :coded, ->(code) { where(code: code) }

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
