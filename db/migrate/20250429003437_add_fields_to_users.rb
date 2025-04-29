class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Basic profile fields
    add_column :users, :name, :string
    add_column :users, :username, :string

    # Avatar handling
    add_column :users, :avatar_url, :string
    add_column :users, :use_gravatar, :boolean, default: true

    # Authentication fields
    add_column :users, :provider, :string  # For OAuth (e.g., 'google', 'github')
    add_column :users, :uid, :string       # Provider's user ID
    add_column :users, :last_sign_in_at, :datetime

    # Additional settings
    add_column :users, :time_zone, :string
    add_column :users, :locale, :string, default: 'en'

    # Account activation
    add_column :users, :is_active, :boolean, default: true

    # Add indexes for faster lookups
    add_index :users, :username, unique: true
    add_index :users, [ :provider, :uid ], unique: true
    add_index :users, :use_gravatar
    add_index :users, :provider
    add_index :users, :time_zone
    add_index :users, :locale
  end
end
