class CreateAuthorizationScopes < ActiveRecord::Migration
  def self.up
    create_table :connect_authorization_scopes do |t|
      t.belongs_to :authorization, :scope
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_authorization_scopes
  end
end
