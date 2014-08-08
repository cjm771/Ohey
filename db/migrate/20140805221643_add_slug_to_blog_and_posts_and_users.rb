class AddSlugToBlogAndPostsAndUsers < ActiveRecord::Migration
  def change
  	add_column :users, :slug, :string
  	 add_index :users, :slug, :unique => true

  	add_column :blogs, :slug, :string
  	 add_index :blogs, :slug, :unique => true

  	add_column :posts, :slug, :string
  	 add_index :posts, :slug, :unique => true
  end
end
