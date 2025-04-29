# db/migrate/YYYYMMDDHHMMSS_create_chats.rb
class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats, id: :uuid do |t|
      t.string :title
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :llm_provider, type: :uuid, null: false, foreign_key: true
      t.jsonb :settings, default: {}
      t.string :status, default: 'active'
      t.datetime :last_activity_at
      t.boolean :thinking_enabled, default: false
      t.boolean :is_favorite, default: false
      t.string :token

      t.timestamps
    end
    add_index :chats, :token, unique: true
  end
end
