class Categorization < ApplicationRecord
  belongs_to :item
  belongs_to :category, counter_cache: true
  validates :category_id, uniqueness: { scope: :item_id}
end
