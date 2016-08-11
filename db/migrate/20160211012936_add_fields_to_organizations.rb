class AddFieldsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :oauth_provider, :string
    add_column :organizations, :oauth_uid, :string
    add_column :organizations, :oauth_name, :string
    add_column :organizations, :oauth_token, :string
    add_column :organizations, :oauth_refresh_token, :string
    add_column :organizations, :oauth_instance_url, :string
  end
end