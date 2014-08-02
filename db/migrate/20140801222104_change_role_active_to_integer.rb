class ChangeRoleActiveToInteger < ActiveRecord::Migration
  def change
  	change_column :roles, :active,  :integer
  end
end
