require 'rails_helper'

describe "auth tests" do
	let(:user){create(:user)}
	it " if user is logged out, goes to target page after logging in" do
		visit "/config"
		sign_in user, password: user.password
		# if success find welcome message
		within("h1") do
			expect(page).to have_content("Settings")
		end
	end
	it "logout returns to homepage" do
		sign_in user, password: user.password
		click_link "Logout"
		expect(page).to have_content("home")
	end

end