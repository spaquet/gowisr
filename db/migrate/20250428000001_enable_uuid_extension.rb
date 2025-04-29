# db/migrate/20250428000001_enable_uuid_extension.rb

class EnableUuidExtension < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto'
  end
end
