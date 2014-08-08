class RolesController < ApplicationController
	before_action :store_location, only: [:accept_invite]
	before_filter :require_user, except: [:show, :accept_invite, :deny_invite]
	before_filter :setup_invite, only: [:show, :accept_invite, :deny_invite]
	respond_to :json

	def create
		# redirect_to config_path+"#users"
		@blog = current_user.current_blog
		@role = @blog.roles.new(role_params)
		# downcase that
		@role.email.downcase!
		 respond_to do |format|
	    if !@current_user.can_edit_role?(@role) 
	    	@role.errors.add :role, "Cannot put a role higher than your own"
	    	 format.json { render json: { :errors => @role.errors}, status: :unprocessable_entity }
	   	elsif !User::is_valid_email?(@role.email)
	    	@role.errors.add :email, "The email you entered is not valid."
	    	format.json { render json: { :errors => @role.errors}, status: :unprocessable_entity }
	    elsif @role.save
	       UserMailer.invite(@role).deliver
	       msg = { :status => "ok", :message => "Invitation was sent to #{@role.email}." }
	       flash[:success] = "#{@role.email} has been invited."
	      format.json { render :json => msg }
	    else
	      format.json { render json: { :errors => @role.errors}, status: :unprocessable_entity }
	    end
	  end
	end

	def accept_invite 
		if !logged_in?
			# send to register or login
			user = User.find_by(:email => @role.email)
			puts "user is"
			puts user.inspect
			if !user
				redirect_to register_path(:email => @role.email), notice: "You'll need to register before accepting this invite"
			else
				redirect_to login_path, notice: "You'll need to login to accept this invite"
			end
			return
		end
		if @current_user.email==@role.email 
			if !@role.update(active: 1, user_id: @current_user.id, token: nil)
				redirect_to config_path+"#invites", error: "We could not accept the invite. Try again later."
			else 
				UserMailer.notify_inviter_someone_accepted(@role).deliver
				redirect_to config_path+"#invites", notice: "Thanks. You can now access that blog by changing to it using the button below."
			end
		else
			redirect_to config_path+"#invites", error: "The invite you tried to accept was not meant for you."
		end
		
	end

	def deny_invite 
		if !@role.update(active: -1, token: nil)
			redirect = logged_in?  ? config_path+"#invites" : invite_path(@role.token)
			redirect_to redirect, error: "We could not deny the invite. Try again later."
		elsif logged_in?
			redirect_to config_path+"#invites", notice: "Thanks. We removed that invite."
		else
			# render success of denial on view page
		end

		UserMailer.notify_inviter_someone_declined(@role).deliver
	end

	def show
		# runs a before filter
	end


  	def update
  		@role = Role.find(params[:id])
  		 respond_to do |format|
			if !@current_user.can_edit_role?(@role) 
				@role.errors.add :role, "Cannot put a role higher than your own"
				 format.json { render json: { :errors => @role.errors}, status: :unprocessable_entity }
			elsif @role.update(role_params)
			   msg = { :status => "ok", :message => "success", :role => @role.role }
			  format.json { render :json => msg }
			else
			  format.json { render json: { :errors => @role.errors}, status: :unprocessable_entity }
			end
		end
	end

  def destroy
   @role = Role.find(params[:id])
    #need to do can_edit? validation here..if not throw error
      if @current_user.can_edit_role?(@role) && @role.destroy
        if @current_user==@role.user
        	notice = 'Cool we removed you from that blog.'
        	# send a notice to creator that someone left
        	UserMailer.notify_user_left(@role).deliver
        else
        	notice = 'Member was successfully deleted.'
        end
        redirect_to config_path+"#users", notice: notice
      else
        flash[:error] = "Unknown error occurred, could not delete that member." 
        redirect_to config_path+"#users"
       end
    end

	 private
	 def setup_invite
	 	@role = Role.find_by(:token => params[:id])
		if logged_in? && @role
			if @current_user.email != @role.email
				redirect_to my_posts_path
				return
			end
		elsif @role==nil || @role.active==-1
			flash[:notice] =  "Invite not found."
			redirect_to root_path
			return
		else
			@inviter = @role.blog.user
			@blog = @role.blog
		end
	 end
    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:email, :role, :active)
    end

end