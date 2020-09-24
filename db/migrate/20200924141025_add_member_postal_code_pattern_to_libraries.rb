class AddMemberPostalCodePatternToLibraries < ActiveRecord::Migration[6.0]
  def change
    add_column :libraries, :member_postal_code_pattern, :string, limit: 100, null: true, default: nil

    library_zero_id = select_value("SELECT id FROM libraries WHERE hostname = 'chicagotoollibrary.herokuapp.com'").presence
    return unless library_zero_id

    reversible do |dir|
      dir.up do
        execute "UPDATE libraries SET member_postal_code_pattern = '60707|60827|^606' WHERE id = #{library_zero_id}"
      end
    end
  end
end
