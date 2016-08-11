class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :org_id

      t.timestamps null: false
    end
  end
end
