class AddPositionToHold < ActiveRecord::Migration[6.1]
  class MigrationHold < ActiveRecord::Base
    self.table_name = "holds"
  end

  class MigrationItem < ActiveRecord::Base
    self.table_name = "items"
    has_many :holds, class_name: "MigrationHold", foreign_key: "item_id"
  end

  def up
    add_column :holds, :position, :integer

    MigrationItem.find_each do |item|
      item.holds.order(:created_at).each.with_index(1) do |hold, index|
        hold.update_column :position, index
      end
    end

    change_column_null :holds, :position, false

    add_index :holds, [:item_id, :position], unique: true
  end

  def down
    remove_column :holds, :position
  end
end
