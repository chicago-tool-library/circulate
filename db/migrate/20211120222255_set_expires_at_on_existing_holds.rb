class SetExpiresAtOnExistingHolds < ActiveRecord::Migration[6.1]
  def up
    execute "UPDATE holds SET expires_at = started_at + interval '#{Hold::HOLD_LENGTH.to_i}' second"
  end
end
