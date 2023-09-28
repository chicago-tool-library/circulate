class AddPowerSourceToItems < ActiveRecord::Migration[6.0]
  def change
    create_enum :power_source, ["solar", "gas", "air", "electric (corded)", "electric (battery)"]

    change_table :items do |t|
      t.enum :power_source, enum_type: :power_source
    end
  end
end
