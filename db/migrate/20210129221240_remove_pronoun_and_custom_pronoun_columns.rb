# frozen_string_literal: true

class RemovePronounAndCustomPronounColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :pronoun
    remove_column :members, :custom_pronoun
  end
end
