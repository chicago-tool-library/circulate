class EstablishTenantZero < ActiveRecord::Migration[6.0]
  def up
    execute "INSERT INTO libraries (#{LIBRARY.keys.join(', ')}, created_at, updated_at)"\
            " VALUES (#{LIBRARY.values.map(&connection.method(:quote)).join(', ')}, NOW(), NOW())"

    TABLES.each do |table|
      execute "UPDATE #{table} SET library_id = #{library_id} WHERE library_id IS NULL"
    end
  end

  def down
    TABLES.each do |table|
      execute "UPDATE #{table} SET library_id = NULL WHERE library_id = #{library_id}"
    end

    execute "DELETE FROM libraries WHERE id = #{library_id}"
  end

  private

  def library_id
    @library_id ||= select_value("SELECT id FROM libraries WHERE hostname = #{connection.quote(LIBRARY[:hostname])}").presence ||
      (raise "Error updating #{LIBRARY[:name]} record")
  end

  LIBRARY = {
    name: "Chicago Tool Library",
    hostname: "chicagotoollibrary.herokuapp.com",
    member_postal_code_pattern: '60707|60827|^606',
  }.freeze
  TABLES = %w[
    users
    members
    memberships
    items
    loans
    documents
    borrow_policies
    hold_requests
    gift_memberships
    notifications
    holds
    categories
    events
    short_links
  ].freeze

  private_constant :LIBRARY, :TABLES
end
