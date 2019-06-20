class UpdateMemberFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :id_number, :string
    add_column :members, :postal_code, :string
  end
end
