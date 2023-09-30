# frozen_string_literal: true

class AddUrlToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :url, :string
  end
end
