class AddEmailToRole < ActiveRecord::Migration
  def change
  	add_column :roles, :email, :string
  end
end
