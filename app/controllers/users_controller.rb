class UsersController < ApplicationController
	
	before_filter :store_location, only: [:edit, :my_posts]
	before_filter :require_user, only: [:edit, :my_posts]
	respond_to :json, only: [:update]

	def new
		@user =User.new
	end

	def create
		@user = User.new(user_params)

		respond_to do |format|
		  if @user.save
		    session[:user_id] = @user.id
		    flash[:success] = "Thanks for signing up!"
		    format.html { redirect_to new_blog_path, success: "Thanks for signing up!" }
		    format.json { render :show, status: :created, location: @user }
		  else
		    format.html { render :new }
		    format.json { render json: @user.errors, status: :unprocessable_entity }
		  end
		end
	end

	def load_blog
		if current_user.is_blog_member? params[:id]  &&  current_user.update_attribute(:current_blog_id,params[:id])
			flash[:notice] = "Successfully loaded '#{current_user.current_blog.title}'"
		else
			blog = Blog.find(params[:id])
			flash[:error] = "Could not load '#{blog.title}'. Sorry."
		end
		redirect_to config_path
	end

	def update
	  respond_to do |format|
	    if current_user.update(user_params)
	       msg = { :status => "ok", :message => "Success!" }
	      format.json { render :json => msg }
	    else
	      format.json { render json: {:model => current_user.reload, :errors => current_user.errors}, status: :unprocessable_entity }
	    end
	  end
	end

	def my_posts
		# first get current blog
		@blog = current_user.current_blog if current_user.current_blog!=nil
		if !@blog
			return redirect_to new_blog_path
		end
		#purge empty posts
		@blog.posts.each do |p|
			if p.user==current_user && p.empty?
				p.destroy
			end
		end

		#refresh blog
		@blog.reload
	end

	def edit
		#need to be logged in for this one

		#me 
		@user = current_user
		#all blogs one collaborates on
		@allRoles = current_user.all_roles
		#active / current blog
		@blog = current_user.current_blog  if current_user.current_blog!=nil
		@role = @blog.roles.new
	end

	private
	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
	  params.require(:user).permit(:first_name, :last_name, :about, :email, :password, :password_confirmation)
	end

end
