class CreateHoldRequestItems < ActiveRecord::Migration[6.0]
  def change
    create_table :hold_request_items do |t|
      t.references :member, foreign_key: true
      t.references :item, foreign_key: true
      t.timestamps
    end
  end
end
