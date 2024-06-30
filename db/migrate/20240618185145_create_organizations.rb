class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.text :name
      t.text :website
      t.references :library, null: false, foreign_key: true

      t.timestamps
    end
    add_index :organizations, [:library_id, :name], unique: true
    add_index :organizations, [:library_id, :website], unique: true
  end
end
