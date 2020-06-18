class AddOtherNamesToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :other_names, :string
  end
end
