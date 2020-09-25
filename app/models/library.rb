class Library < ApplicationRecord
  validates :name, presence: true
  validates :hostname, presence: true, uniqueness: true

  has_one_attached :image

  def allows_postal_code?(postal_code)
    return true if postal_code.blank?

    /#{member_postal_code_pattern}/ =~ postal_code.to_s
  end
end
