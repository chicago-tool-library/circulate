class ItemAttachment < ApplicationRecord
  belongs_to :item
  belongs_to :creator, class_name: "User"

  has_one_attached :file

  enum :kind, {
    "manual" => "manual",
    "parts_list" => "parts_list",
    "other" => "other"
  }

  validates :kind, inclusion: {in: ItemAttachment.kinds.keys}
  validate :file_is_attached

  private

  def file_is_attached
    errors.add(:file, "is required") unless file.attached?
  end
end
