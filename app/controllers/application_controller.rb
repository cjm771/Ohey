class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
   #check if user is logged in
  before_action :logged_in?

  private
  def logged_in?
    current_user
  end
  helper_method :logged_in?
  
  def current_user
  	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def store_location
      #lets grab it for later
      session[:return_to] = request.url
  end
  def require_user
  	if current_user
  		true
  	else
  		redirect_to login_path, notice: "You must be logged in to access that page."
  	end
  
  end

end
