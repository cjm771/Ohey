class RolesController < ApplicationController
	
	before_filter :require_user
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
        redirect_to config_path+"#users", notice: 'Member was successfully deleted.'
      else
        flash[:error] = "Unknown error occurred, could not delete that member." 
        redirect_to config_path+"#users"
       end
    end

	 private
    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:email, :role)
    end

end