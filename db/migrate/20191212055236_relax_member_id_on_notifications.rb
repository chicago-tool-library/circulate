class RelaxMemberIdOnNotifications < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notifications, :member_id, true
  end
end
