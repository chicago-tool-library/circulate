# frozen_string_literal: true

class AddLibraryIdToRenewalRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :renewal_requests, :library_id, :integer
    add_index :renewal_requests, :library_id
  end
end
