class AddMemberPostalCodePatternToLibraries < ActiveRecord::Migration[6.0]
  def change
    add_column :libraries, :member_postal_code_pattern, :string, limit: 100, null: true, default: nil
  end
end
