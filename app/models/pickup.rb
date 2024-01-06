class Pickup < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :reservation
end
