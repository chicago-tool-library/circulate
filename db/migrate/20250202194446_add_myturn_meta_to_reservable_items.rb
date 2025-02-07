class AddMyturnMetaToReservableItems < ActiveRecord::Migration[7.2]
  def change
    add_column :reservable_items, :myturn_metadata, :jsonb, default: {}
  end
end
