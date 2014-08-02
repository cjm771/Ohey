 require 'rails_helper'


describe "Blog features" do
	context "logged in" do
	 let(:user){create(:user)}
  
      before do
        sign_in user, password: user.password
      end
	  it "get error if creates a blog with less than 2 characters" do
	    visit blogs_new_path
	    fill_in "#{user.first_name}'s blog", with: "x"
	    click_button "Create Blog"
	    expect(page).to have_content("error")
	  end
	  it "is successful when submitted with no fields (creates default)" do
		visit blogs_new_path
		expect(user.current_blog_id).to be_nil
		click_button "Create Blog"
		expect(page).to_not have_content("error")
		user.reload
		expect(user.current_blog_id).to eq(1)
		expect(user.current_blog.title).to have_content("#{user.first_name}'s Blog")
		expect(page).to have_content("#{user.first_name}'s Blog")
	  end
	  it "is successful when custom blog name 'My dope blog'" do
	  	visit blogs_new_path
		expect(user.current_blog_id).to be_nil
		fill_in "#{user.first_name}'s blog",  with: "My dope blog"
		click_button "Create Blog"
		expect(page).to_not have_content("error")
		user.reload
		expect(user.current_blog_id).to eq(1)
		expect(user.current_blog.title).to eq("My dope blog")
		expect(page).to have_content("My dope blog")
	  end

	  it "assigns creator role when creating a blog" do
	  	visit blogs_new_path
		expect(user.current_blog_id).to be_nil
		fill_in "#{user.first_name}'s blog",  with: "My dope blog"
		click_button "Create Blog"
		expect(page).to_not have_content("error")
		user.reload
		expect(user.current_blog_id).to eq(1)
		expect(Role.count).to eq(1)
		pp Role.all
		expect(user.current_blog).to_not be_nil
		expect(user.current_role).to_not be_nil
		expect(page).to have_content("My dope blog")
	  end
	end

	context "logged out" do
		it "redirects to login if access my_posts" do
			visit my_posts_path
			expect(page).to have_content('Login')
		end

	end

end