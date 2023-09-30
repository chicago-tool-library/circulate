# frozen_string_literal: true

class AddPlainTextDescriptionToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :plain_text_description, :text
  end
end
