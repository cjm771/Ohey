class PostsController < ApplicationController
    before_action :store_location
    before_action :require_user, except: [:show]
    before_action :set_blog
    respond_to :json, only: [:update]

  def new
    if @current_user.is_blog_member? @blog.id
      @post = @blog.posts.create user_id: current_user.id
      render action: "edit"
    else
      redirect_to my_posts_path, notice: "You're not a member of that blog"
    end
  end

  def edit
   
    
      @post ||= @blog.posts.find(params[:id])
        #if this is an actual edit and not a new post
    if !@current_user.can_edit_post? @post
       redirect_to my_posts_path, notice: "You're not  authorized to edit that post."
    end
  end

  def show 
    @post = Post.friendly.find(params[:id])
    if (@post)
       @blog = @post.blog
    end    
  end

  def update
    @post = @blog.posts.find(params[:id])
   
    respond_to do |format|
       #need to do can_edit? validation here..if not throw error
      if @current_user.can_edit_post? @post
        if @post.update(post_params)
           msg = { :status => "ok", :message => "Success!" }
          format.json { render :json => msg }
        else
          format.json { render json: {:model => @post.reload, :errors => @post.errors}, status: :unprocessable_entity }
        end
      else
        @post.errors.add :title, "You're not authorized to edit this post."
        format.json { render json: { :errors => @post.errors}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
   @post = @blog.posts.find(params[:id])
    #need to do can_edit? validation here..if not throw error
      if @current_user.can_edit_post? @post
        if @post.destroy
          redirect_to my_posts_path, notice: 'Post was successfully deleted.'
        else
          flash[:error] = "Unknown error occurred, could not delete '#{@post.title}'." 
          redirect_to my_posts_path
         end
       else
          flash[:error] = "You're not authorized to delete this post." 
          redirect_to my_posts_path
       end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      if current_user
        @blog = current_user.current_blog
        if !@blog
          redirect_to my_posts_path
        end
      end
    end

   # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
    params.require(:post).permit(:title, :description, :published)
  end
end
