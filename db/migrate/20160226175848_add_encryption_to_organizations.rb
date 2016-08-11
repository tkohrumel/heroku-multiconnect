class AddEncryptionToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :encrypted_oauth_token, :string
    add_column :organizations, :encrypted_oauth_token_iv, :string
  end
end