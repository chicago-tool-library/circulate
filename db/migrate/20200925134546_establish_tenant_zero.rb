class EstablishTenantZero < ActiveRecord::Migration[6.0]
  def up
    execute "INSERT INTO libraries (#{LIBRARY.keys.join(", ")}, created_at, updated_at)" \
            " VALUES (#{LIBRARY.values.map(&connection.method(:quote)).join(", ")}, NOW(), NOW())"

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

  ADDRESS = <<~ADDRESS.strip
    The Chicago Tool Library
    1048 W 37th Street Suite 102
    Chicago, IL 60609
    chicagotoollibrary.org
  ADDRESS
  LIBRARY = {
    name: "Chicago Tool Library",
    hostname: "chicagotoollibrary.herokuapp.com",
    city: "Chicago",
    email: "team@chicagotoollibrary.org",
    address: ADDRESS,
    member_postal_code_pattern: "60707|60827|^606"
  }.freeze
  TABLES = %w[
    users
    members
    memberships
    items
    loans
    documents
    borrow_policies
    gift_memberships
    notifications
    holds
    categories
    events
    short_links
  ].freeze

  private

  def library_id
    @library_id ||= select_value("SELECT id FROM libraries WHERE hostname = #{connection.quote(LIBRARY[:hostname])}").presence ||
      (raise "Error updating #{LIBRARY[:name]} record")
  end

  private_constant :LIBRARY, :TABLES
end
