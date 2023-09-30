# frozen_string_literal: true

class MakeMembershipsPending < ActiveRecord::Migration[6.0]
  def change
    change_column_null :memberships, :started_on, true
    change_column_default :memberships, :started_on, nil
    change_column_null :memberships, :ended_on, true
    change_column_default :memberships, :ended_on, nil
  end
end
