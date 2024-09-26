class RequireOrganizationName < ActiveRecord::Migration[7.2]
  def up
    change_column :organizations, :name, :text, null: false
  end

  def down
    change_column :organizations, :name, :text, null: true
  end
end
