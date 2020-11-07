class DowncaseEmails < ActiveRecord::Migration[6.0]
  def change
    execute "UPDATE members SET email = LOWER(email)"
  end
end
