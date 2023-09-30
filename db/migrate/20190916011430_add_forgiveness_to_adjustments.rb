# frozen_string_literal: true

class AddForgivenessToAdjustments < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_enum_value :adjustment_source, "forgiveness"
  end
end
