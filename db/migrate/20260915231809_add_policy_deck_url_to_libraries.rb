class AddPolicyDeckUrlToLibraries < ActiveRecord::Migration[8.0]
  def change
    add_column :libraries, :policy_deck_url, :string
  end
end
