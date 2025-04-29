# db/migrate/YYYYMMDDHHMMSS_create_messages.rb
class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :chat, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, foreign_key: true
      t.text :content
      t.string :role # user, assistant, system, thinking
      t.jsonb :metadata, default: {}
      t.float :tokens_used
      t.boolean :is_thinking, default: false
      t.string :status, default: 'complete'

      t.timestamps
    end
  end
end
