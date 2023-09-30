# frozen_string_literal: true

class CreateAgreementAcceptances < ActiveRecord::Migration[6.0]
  def change
    create_table :agreement_acceptances do |t|
      t.references :agreement, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
