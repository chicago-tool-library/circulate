class AddNoticeToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :checkout_notice, :string
  end
end
