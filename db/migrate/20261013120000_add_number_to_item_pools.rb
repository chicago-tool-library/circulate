class AddNumberToItemPools < ActiveRecord::Migration[8.0]
  def up
    add_column :item_pools, :number, :integer
    add_index :item_pools, [:number, :library_id], unique: true, where: "number IS NOT NULL"

    # Unnumbered pools share a number space with reservable items, so continue numbering
    # from the highest number used by either within each library.
    execute <<~SQL
      WITH starting_numbers AS (
        SELECT libraries.id AS library_id,
          GREATEST(
            (SELECT MAX(number) FROM reservable_items WHERE reservable_items.library_id = libraries.id),
            (SELECT MAX(number) FROM item_pools WHERE item_pools.library_id = libraries.id),
            0
          ) AS max_number
        FROM libraries
      ),
      numbered_pools AS (
        SELECT item_pools.id,
          starting_numbers.max_number + ROW_NUMBER() OVER (PARTITION BY item_pools.library_id ORDER BY item_pools.id) AS new_number
        FROM item_pools
        JOIN starting_numbers ON starting_numbers.library_id = item_pools.library_id
        WHERE item_pools.uniquely_numbered = FALSE
      )
      UPDATE item_pools SET number = numbered_pools.new_number
      FROM numbered_pools
      WHERE item_pools.id = numbered_pools.id
    SQL
  end

  def down
    remove_index :item_pools, [:number, :library_id]
    remove_column :item_pools, :number
  end
end
