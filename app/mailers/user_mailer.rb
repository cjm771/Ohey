class UserMailer < ActionMailer::Base

  default from: '"O..Hey" <no-reply@ohey.mailgun.org>'

  def invite(role)
  	@role = role
  	@blog = role.blog
  	@creator = @blog.user
 
  	mail(to: @role.email, subject: "#{@creator.full_name.capitalize} invites you to collaborate on '#{@blog.title.capitalize}'")
  end

  def notify_inviter_someone_accepted(role)
    @role = role
    @blog = role.blog
    @creator = @blog.user
 
    mail(to: @creator.email, subject: "#{@role.email} accepted your invite to collaborate on '#{@blog.title.capitalize}'")
  end

  def notify_user_left(role)
    @role = role
    @blog = role.blog
    @creator = @blog.user
 
    mail(to: @creator.email, subject: "#{@role.user.full_name} left the blog '#{@blog.title.capitalize}'")
  end

  def notify_blog_delete(creator, blog, role)
    @role = role
    @blog = blog
    @creator = creator
    puts "what is this thing"
    puts @role.inspect
    @to_name = User.find(@role["user_id"]).first_name
 
    mail(to: @role["email"], subject: "#{@creator.first_name} deleted '#{@blog.title.capitalize}'")
  end

  def password_reset(user)
    @user = user
    mail( to: "#{user.first_name} #{user.last_name} <#{user.email}>",
        subject: "Reset your password")
  end


  def notify_inviter_someone_declined(role)
  	@role = role
  	@blog = role.blog
  	@creator = @blog.user
 
  	mail(to: @creator.email, subject: "#{@role.email} denied your invite to collaborate on '#{@blog.title.capitalize}'")
  end
end
