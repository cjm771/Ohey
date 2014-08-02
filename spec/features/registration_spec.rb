require "rails_helper"

describe "Signing up" do
	it "allows a user to sign up for the site and create the object in db" do
		expect(User.count).to eq(0)

		visit "/"
		expect(page).to have_content("Register")
		click_link "Register"

		fill_in "First Name", with: "Chris"
		fill_in "Last Name", with: "Malcolm"
		fill_in "Email", with: "chris@teamtreehouse.com"
		fill_in "Password", with: "treehouse1234"
		fill_in "Confirm Your Password", with: "treehouse1234"
		click_button "Sign Up"

		expect(User.count).to eq(1) 
		expect(page).to have_content("Thanks for signing up!")
		expect(page).to have_content("Create a Blog")
	end
end