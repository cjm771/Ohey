require 'rails_helper'

RSpec.describe BlogsController, :type => :controller do

  describe "GET 'new'" do
    context "logged in" do
      let(:user){create(:user)}
      
      before do
        sign_in(user)
      end
      
      it "redirects to blogs/new when logged in" do
        get 'new'
        response.should render_template("new")
      end

    end


    context "logged out" do
      it "redirects to login page if logged out" do
      	get 'new'
      	response.should redirect_to(login_path)
      end
    end
  end

end
