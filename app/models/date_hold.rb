class DateHold < ApplicationRecord
  belongs_to :reservation
  belongs_to :reservable_item
end
