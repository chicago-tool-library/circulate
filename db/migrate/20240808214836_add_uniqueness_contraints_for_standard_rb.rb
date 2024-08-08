class AddUniquenessContraintsForStandardRb < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # Remove these since they aren't unique
    remove_index(:categorizations, %i[categorized_id category_id], unique: false, algorithm: :concurrently)
    remove_index(:short_links, %i[library_id slug], unique: false, algorithm: :concurrently)

    index_options = {unique: true, algorithm: :concurrently}

    add_index(:borrow_policies, %i[code library_id], **index_options)
    add_index(:categorizations, %i[category_id categorized_id], **index_options)
    add_index(:reservation_holds, %i[item_pool_id reservation_id], **index_options)
    add_index(:reservation_loans, %i[reservable_item_id reservation_hold_id], **index_options)
    add_index(:short_links, %i[slug library_id], **index_options)
    add_index(:short_links, %i[url library_id], **index_options)
  end
end
