class BlogsController < ApplicationController
  
  before_action :store_location
  before_action :require_user
   

  def new
  	@blog = current_user.blogs.new
  end

  def update
    @blog = current_user.current_blog
    # make sure this dude is creator
    if current_user.is_creator?(@blog.id) == false
      respond_to do |format|
         format.json { render :json => { :error => true, :message => "Error 422, Rejected." } }
      end
    else
      respond_to do |format|
        if @blog.update(blog_params)
           msg = { :status => "ok", :message => "Success!" }
          format.json { render :json => msg }
        else
          format.json { render json: {:model => @blog.reload, :errors => @blog.errors}, status: :unprocessable_entity }
        end
      end
    end
  end
  
  def create
    @blog = current_user.blogs.new(blog_params)

    respond_to do |format|
      if @blog.save
        #also update current_blog_id for user
        current_user.update_attribute(:current_blog_id, @blog.id)
        #save role for user
        @blog.roles.create active: 1, user_id: current_user.id, role: Role::CREATOR
        format.html { redirect_to my_posts_path, notice: 'Blog was successfully created.' }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new}
        format.json { render json: @blog_params.errors, status: :unprocessable_entity }
      end
    end
  end

    private
    # Never trust parameters from the scary internet, only allow the white list through.
    def blog_params
      params.require(:blog).permit(:title, :description)
    end
end
