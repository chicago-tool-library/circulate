class AddMissingToItemStatuses < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :item_status, "missing"
  end
end
