class AddSchemaNameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :schema_name, :string 
  end
end