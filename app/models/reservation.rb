class Reservation < ApplicationRecord
  belongs_to :member
  belongs_to :item
  belongs_to :created_by, class_name: "User"
end
