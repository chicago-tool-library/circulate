class CreateItemAttachments < ActiveRecord::Migration[6.0]
  def change
    create_enum :item_attachment_kind, ["manual", "parts_list", "other"]

    create_table :item_attachments do |t|
      t.belongs_to :item, null: false, foreign_key: true
      t.belongs_to :creator, null: false, foreign_key: {to_table: :users}
      t.enum :kind, enum_type: :item_attachment_kind
      t.string :other_kind
      t.string :notes

      t.timestamps
    end
  end
end
