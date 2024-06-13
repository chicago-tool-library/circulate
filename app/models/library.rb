class Library < ApplicationRecord
  validates :name, presence: true
  validates :hostname, presence: true, uniqueness: true
  validates :city, presence: true
  validates :email, presence: true
  validates :maximum_reservation_length, presence: true
  validates :minimum_reservation_start_distance, presence: true
  validates :maximum_reservation_start_distance, presence: true
  validates_numericality_of :maximum_reservation_length,
    only_integer: true, greater_than: 0
  validates_numericality_of :minimum_reservation_start_distance,
    only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :maximum_reservation_start_distance,
    only_integer: true, greater_than: 0
  validate :member_postal_code_regexp
  validate :maximum_reservation_start_distance_is_greater_than_minimum

  has_one_attached :image
  has_many :documents
  has_many :users
  has_many :members

  has_rich_text :email_banner1
  has_rich_text :email_banner2

  after_create :create_docs

  def allows_postal_code?(postal_code)
    return true if postal_code.blank?
    return true if member_postal_code_pattern.blank?

    Regexp.new(member_postal_code_pattern) =~ postal_code.to_s
  end

  def admissible_postal_codes
    member_postal_code_pattern
      .delete("^")
      .split("|")
      .map { |postal_code| postal_code.ljust(5, "x") }
  end

  def valid_reservation_started_at?(started_at)
    minimum = minimum_reservation_start_distance.days.from_now.beginning_of_day
    maximum = maximum_reservation_start_distance.days.from_now.end_of_day

    minimum <= started_at && maximum >= started_at
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
    rescue => e
      logger.debug "Error parsing `member_postal_code_pattern` `#{member_postal_code_pattern}': #{e}"
      errors.add(:member_postal_code_pattern, :invalid)
    end
  end

  def maximum_reservation_start_distance_is_greater_than_minimum
    if minimum_reservation_start_distance? && maximum_reservation_start_distance? && minimum_reservation_start_distance >= maximum_reservation_start_distance
      errors.add(:maximum_reservation_start_distance, "must be greater than the mininum reservation start distance")
    end
  end
end
