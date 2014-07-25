class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user, index: true
      t.references :blog, index: true
      t.boolean :active
      t.integer :role
      t.string :token

      t.timestamps
    end
  end
end
