class ChangeLibrariesHostnameNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :libraries, :hostname, false
  end
end
