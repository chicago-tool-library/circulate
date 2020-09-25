class Library < ApplicationRecord
  validates :name, presence: true
  validates :hostname, presence: true, uniqueness: true
  validate :member_postal_code_regexp

  has_one_attached :image
  has_many :documents

  after_create :create_docs

  def allows_postal_code?(postal_code)
    return true if postal_code.blank?

    /#{member_postal_code_pattern}/ =~ postal_code.to_s
  end

  private

  def create_docs
    documents.create!(name: "Borrow Policy", code: "borrow_policy", summary: "Covers the rules of borrowing. Shown on the first page of member signup.")
    documents.create!(name: "Agreement", code: "agreement", summary: "Member Waiver of Indemnification")
  end

  def member_postal_code_regexp
    return if member_postal_code_pattern.blank?

    begin
      Regexp.new(member_postal_code_pattern)
    rescue StandardError => e
      logger.debug "Error parsing `member_postal_code_pattern` `#{member_postal_code_pattern}': #{e}"
      errors.add(:member_postal_code_pattern, :invalid)
    end
  end
end
