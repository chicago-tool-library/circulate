class RenameMembershipStartedOnAndEndedOn < ActiveRecord::Migration[6.0]
  def change
    rename_column(:memberships, :started_on, :started_at)
    rename_column(:memberships, :ended_on, :ended_at)
  end
end
