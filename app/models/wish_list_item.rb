class WishListItem < ApplicationRecord
  belongs_to :item
  belongs_to :member

  validates :item, uniqueness: {scope: :member}
end
