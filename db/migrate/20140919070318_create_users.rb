class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: :uuid do |t|

      t.string :roles

      t.string :name
      t.string :surname
      t.string :avatar

      t.string :login

      t.string :email, null: false, default: ''
      t.string :password_digest, null: false, default: ''
      t.string :restore_password_token
      t.datetime :restore_password_sent_at

      t.boolean :is_active
      t.datetime :confirmed_at

      t.timestamps
    end
    add_index :users, :login
    add_index :users, :roles
    add_index :users, :email
    add_index :users, :restore_password_token
  end
end
