class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :stytch_user_id
      t.boolean :verified

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :stytch_user_id, unique: true
  end
end
