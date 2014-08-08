class PagesController < ApplicationController
  def home
  	@blogs = Blog::ranked_blogs.first(7)
  	@users = User::ranked_users
  	@posts = Post.where(:published => true).last(7).reverse
  end

  def help
  end

  def about 
  end
end
