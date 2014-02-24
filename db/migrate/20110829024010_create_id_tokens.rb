class CreateIdTokens < ActiveRecord::Migration
  def self.up
    create_table :connect_id_tokens do |t|
      t.belongs_to :account, :client
      t.string :nonce
      t.datetime :expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_id_tokens
  end
end
