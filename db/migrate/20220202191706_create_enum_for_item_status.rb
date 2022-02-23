class CreateEnumForItemStatus < ActiveRecord::Migration[6.1]
  class Item < ActiveRecord::Base
    enum status: [:pending, :active, :maintenance, :retired]
  end

  def change
    reversible do |migrate|
      migrate.up do
        create_enum :item_status, ["pending", "active", "maintenance", "retired"]
      end

      migrate.down do
        drop_enum :item_status
      end
    end

    pending_int = Item.statuses[:pending]
    active_int = Item.statuses[:active]
    maintenance_int = Item.statuses[:maintenance]
    retired_int = Item.statuses[:retired]

    reversible do |migrate|
      migrate.up do
        execute <<~SQL
          alter table items
            alter column status drop default,
            alter column status set data type item_status using case
            when status = #{pending_int} then 'pending'::item_status
            when status = #{active_int} then 'active'::item_status
            when status = #{maintenance_int} then 'maintenance'::item_status
            when status = #{retired_int} then 'retired'::item_status
            end,
            alter column status set default 'active';
        SQL
      end

      migrate.down do
        execute <<~SQL
          alter table items
            alter column status drop default,
            alter column status set data type integer using case
            when status = 'pending' then #{pending_int}
            when status = 'active' then #{active_int}
            when status = 'maintenance' then #{maintenance_int}
            when status = 'retired' then #{retired_int}
            end,
            alter column status set default #{active_int};
        SQL
      end
    end
  end
end
