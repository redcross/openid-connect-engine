class CreateScopes < ActiveRecord::Migration
  def self.up
    create_table :connect_scopes do |t|
      t.string :name
      t.timestamps
    end
    add_index :connect_scopes, :name, unique: true
  end

  def self.down
    drop_table :connect_scopes
  end
end
