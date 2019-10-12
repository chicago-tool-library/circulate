class AddKindToAdjustments < ActiveRecord::Migration[6.0]
  def change
    create_enum :adjustment_kind, ["fine", "membership", "donation", "payment"]

    change_table :adjustments do |t|
      t.enum :kind, enum_name: :adjustment_kind
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE adjustments SET kind='payment' WHERE adjustable_type IS NULL;
          UPDATE adjustments SET kind='fine' WHERE adjustable_type = 'Loan';
          UPDATE adjustments SET kind='membership' WHERE adjustable_type = 'Membership';
        SQL
      end
    end
    change_column_null :adjustments, :kind, false
  end
end
