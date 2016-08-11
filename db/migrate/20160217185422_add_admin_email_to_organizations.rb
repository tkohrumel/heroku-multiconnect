class AddAdminEmailToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :admin_email, :string
  end
end