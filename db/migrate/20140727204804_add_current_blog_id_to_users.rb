class AddCurrentBlogIdToUsers < ActiveRecord::Migration
  def change
  		add_column :users, :current_blog_id, :Integer
  		add_index :users, :current_blog_id
  end
end
