class AddAuthUrlToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :authorize_url, :string
  end
end