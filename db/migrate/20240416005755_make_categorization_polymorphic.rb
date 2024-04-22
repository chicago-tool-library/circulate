class MakeCategorizationPolymorphic < ActiveRecord::Migration[7.1]
  def change
    add_column :categorizations, :categorized_type, :text
    rename_column :categorizations, :item_id, :categorized_id

    reversible do |direction|
      direction.up { execute "UPDATE categorizations SET categorized_type = 'Item'" }
    end

    change_column_null :categorizations, :categorized_type, false
  end
end
