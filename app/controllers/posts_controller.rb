class PostsController < ApplicationController
    before_action :store_location
    before_action :require_user
    before_action :set_blog
    respond_to :json, only: [:update]

  def new
    @post = @blog.posts.create user_id: current_user.id
    render action: "edit"
  end

  def edit
    #if this is an actual edit and not a new post
    @post ||= @blog.posts.find(params[:id])
    
  end

  def update
    @post = @blog.posts.find(params[:id])
    #need to do can_edit? validation here..if not throw error
    respond_to do |format|
      if @post.update(post_params)
         msg = { :status => "ok", :message => "Success!" }
        format.json { render :json => msg }
      else
        format.json { render json: {:model => @post.reload, :errors => @post.errors}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
   @post = @blog.posts.find(params[:id])
    #need to do can_edit? validation here..if not throw error
      if @post.destroy
        redirect_to my_posts_path, notice: 'Post was successfully deleted.'
      else
        flash[:error] = "Unknown error occurred, could not delete '#{@post.title}'." 
        redirect_to my_posts_path
       end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = current_user.current_blog
      if !@blog
        redirect_to my_posts_path
      end
    end

   # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
    params.require(:post).permit(:title, :description, :published)
  end
end
