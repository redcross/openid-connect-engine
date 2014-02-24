class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :connect_authorizations do |t|
      t.belongs_to :account, :client
      t.string :code, :nonce, :redirect_uri
      t.datetime :expires_at
      t.timestamps
    end
    add_index :connect_authorizations, :code, unique: true
  end

  def self.down
    drop_table :connect_authorizations
  end
end
