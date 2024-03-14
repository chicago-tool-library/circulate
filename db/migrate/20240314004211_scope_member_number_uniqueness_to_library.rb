class ScopeMemberNumberUniquenessToLibrary < ActiveRecord::Migration[7.1]
  def change
    remove_index :members, :number, unique: true
    remove_index :members, [:number, :library_id]
    add_index :members, [:library_id, :number], unique: true
  end
end
