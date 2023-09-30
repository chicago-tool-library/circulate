# frozen_string_literal: true

class AddAdditionalItemStatuses < ActiveRecord::Migration[6.1]
  def change
    add_enum_value :item_status, "maintenance_repairing"
    add_enum_value :item_status, "maintenance_parts"
  end
end
