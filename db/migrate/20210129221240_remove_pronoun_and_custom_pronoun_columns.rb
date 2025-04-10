class RemovePronounAndCustomPronounColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :pronoun # standard:disable Rails/ReversibleMigration
    remove_column :members, :custom_pronoun # standard:disable Rails/ReversibleMigration
  end
end
