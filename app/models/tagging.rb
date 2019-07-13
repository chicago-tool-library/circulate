class Tagging < ApplicationRecord
  belongs_to :item
  belongs_to :tag, counter_cache: true
  validates :tag_id, uniqueness: {scope: :item_id}
end
