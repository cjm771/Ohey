class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.boolean :published
      t.references :blog, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
