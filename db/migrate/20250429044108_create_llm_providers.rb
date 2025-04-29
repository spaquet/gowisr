# db/migrate/YYYYMMDDHHMMSS_create_llm_providers.rb
class CreateLlmProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_providers, id: :uuid do |t|
      t.string :name, null: false
      t.string :provider_type, null: false # anthropic, openai, etc.
      t.string :model_name, null: false # claude-3-opus, gpt-4, etc.
      t.jsonb :default_parameters, default: {}
      t.text :description
      t.boolean :supports_thinking, default: false
      t.boolean :supports_files, default: false
      t.integer :token_limit
      t.boolean :active, default: true
      t.integer :max_file_size_mb, default: 10
      t.integer :max_files, default: 5
      t.string :avatar_url

      t.timestamps
    end
    add_index :llm_providers, [ :provider_type, :model_name ], unique: true
  end
end
