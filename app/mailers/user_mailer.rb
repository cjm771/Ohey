class UserMailer < ActionMailer::Base
  default from: "no-reply@ohey.herokuapp.com"
  default_url_options[:host] = Rails.env.production?  ?  "ohey.herokuapp.com" : "localhost:3000" 

  def invite(role)
  	@role = role
  	@blog = role.blog
  	@creator = @blog.user
 
  	mail(to: @role.email, subject: "#{@creator.full_name.capitalize} invites you to collaborate on '#{@blog.title.capitalize}'")
  end
end
