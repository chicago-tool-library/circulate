class Categorization < ApplicationRecord
  belongs_to :item
  belongs_to :category
  validates :category_id, uniqueness: { scope: :item_id}
end
