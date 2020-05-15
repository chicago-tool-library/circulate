class Hold < ApplicationRecord
  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
end
