class ConvertNoHoldsItemsToOneDayHolds < ActiveRecord::Migration[8.0]
  def up
    Item.where(status: "active", holds_enabled: false).find_each do |item|
      item.update!(
        holds_enabled: true,
        hold_duration: 1,
        audit_comment: "Converted from no-holds to 1-day hold (issue #2157)"
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
