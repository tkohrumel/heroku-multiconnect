class AddConnectionIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :connection_id, :string
  end
end