class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :title
      t.text :description
      t.references :user, index: true
      t.text :options

      t.timestamps
    end
  end
end
