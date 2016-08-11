class AddEnvironmentToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :environment, :string
  end
end