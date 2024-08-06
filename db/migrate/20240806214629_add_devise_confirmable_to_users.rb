class AddDeviseConfirmableToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table(:users) do |t|
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.index :confirmation_token, unique: true
    end

    reversible do |direction|
      direction.up { execute "UPDATE users SET confirmation_sent_at=now(), confirmed_at=now()" }
    end
  end
end
