class UserMailer < ActionMailer::Base

  default from: '"O..Hey" <no-reply@ohey.mailgun.org>'

  def invite(role)
  	@role = role
  	@blog = role.blog
  	@creator = @blog.user
 
  	mail(to: @role.email, subject: "#{@creator.full_name.capitalize} invites you to collaborate on '#{@blog.title.capitalize}'")
  end
end
