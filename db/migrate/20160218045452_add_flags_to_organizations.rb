class AddFlagsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :connection_configured, :boolean, default: false
    add_column :organizations, :web_authenticated, :boolean, default: false
  end
end