class ChangeRoleActiveToInteger < ActiveRecord::Migration
  def change
  	change_column :roles, :active,  'integer USING CAST(active AS integer)'
  end
end
