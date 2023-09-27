class AddRolesToUsers < ActiveRecord::Migration[6.0]
  def change
    create_enum :user_role, ["staff", "admin"]

    change_table :users do |t|
      t.enum :role, enum_type: :user_role, default: "staff", null: false
    end
  end
end
