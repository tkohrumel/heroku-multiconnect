class ChangeDefaultForEnvironment < ActiveRecord::Migration
  def change
    change_column_default :organizations, :environment, "production"
  end
end