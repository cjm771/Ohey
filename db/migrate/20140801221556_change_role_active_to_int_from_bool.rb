class ChangeRoleActiveToIntFromBool < ActiveRecord::Migration
  def change
  	change_column :roles, :active,  :int
  end
end
