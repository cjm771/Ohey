class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:email])
  	if user && user.authenticate(params[:password])
  		session[:user_id] = user.id
  		flash[:success] = "Thanks for logging in!"

 	  	redirect_to session[:return_to]||my_posts_path
      session[:return_to] = nil
 	 else
 	 	flash[:error] = "There was a problem logging in. Please check your email and password."
 	 	render action: 'new'
 	 end

  end

  def destroy
    session[:user_id] = nil
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end
end
