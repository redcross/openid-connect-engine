class CreateConnectGrants < ActiveRecord::Migration
  def change
    create_table :connect_grants do |t|
      t.references :client, index: true
      t.references :account, index: true
      t.references :scope, index: true
      t.timestamp :expires_at

      t.timestamps
    end
  end
end
