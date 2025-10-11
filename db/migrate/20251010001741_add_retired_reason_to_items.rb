class AddRetiredReasonToItems < ActiveRecord::Migration[8.0]
  def change
    create_enum :item_retired_reason, %w[
      not_returned
      broken
      upgraded
      used_up
    ], force: :cascade
    add_column :items, :retired_reason, :enum, enum_type: :item_retired_reason
    add_column :reservable_items, :retired_reason, :enum, enum_type: :item_retired_reason
  end
end
