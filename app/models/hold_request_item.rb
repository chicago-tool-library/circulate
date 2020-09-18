class HoldRequestItem < ApplicationRecord
  belongs_to :item
  belongs_to :hold_request
end
