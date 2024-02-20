class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.references :library
      t.string :name

      t.timestamps
    end
    add_index :organizations, [:library_id, :name], unique: true
  end
end
