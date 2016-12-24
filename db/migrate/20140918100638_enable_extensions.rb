class EnableExtensions < ActiveRecord::Migration
  def change
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"
    enable_extension "unaccent"
    enable_extension "citext"
    enable_extension "hstore"
    enable_extension "postgis"
  end
end
