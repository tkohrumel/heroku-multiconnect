class RemoveUnencryptedTokenFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :oauth_token
  end
end