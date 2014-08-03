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
	    if @role.save
	       UserMailer.invite(@role).deliver
	       msg = { :status => "ok", :message => "Invitation was sent to #{@role.email}." }
	      format.json { render :json => msg }
	    else
	      format.json { render json: { :errors => @role.errors}, status: :unprocessable_entity }
	    end
	  end
	end

	 private
    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:email, :role)
    end
end