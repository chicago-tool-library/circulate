class AddUsageFeeToAdjustmentKind < ActiveRecord::Migration[8.1]
  def up
    add_enum_value :adjustment_kind, "usage_fee"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Postgres can't remove enum values"
  end
end
