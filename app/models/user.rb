class User < ActiveRecord::Base
	has_secure_password
	has_many :blogs
	has_many :posts
	has_many :roles
	
	validates :first_name, :last_name, presence: true
	validates :email, presence: true,
					  uniqueness: true,
					  format: {
					  		with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create 
					  }
	before_save :downcase_email
	def downcase_email
		self.email =  email.downcase
	end
	def generate_password_reset_token!
		update_attribute(:password_reset_token, SecureRandom.urlsafe_base64(48))
	end

	def full_name
		self.first_name+" "+self.last_name
	end

	def gravatar_url
		"http://gravatar.com/avatar/"+Digest::MD5.hexdigest(email.strip.downcase)+"?d=mm"
	end

	def self.gravatar_url email
		"http://gravatar.com/avatar/"+Digest::MD5.hexdigest(email.strip.downcase)+"?d=mm"
	end

	def all_roles
		allBlogs = [];
		Role.where(user_id: self.id, active: 1).each do |role|
			if is_blog_member? role.blog_id 
				allBlogs.push role
			end
		end
		allBlogs
	end

	def is_creator? id=self.current_blog_id
		 current_role == Role::CREATOR
	end

	def current_role
		 if is_blog_member?
			#blog should be scoped to user so we find role
			Role.where(blog_id: current_blog.id, user_id: self.id, active: 1).first.role
		end
	end


	def current_role_text
		role = current_role
		if role
			Role::ROLE_TEXT[role]
		end
	end

	#check if blog exists and then if user has a role
	def is_blog_member? id=self.current_blog_id
		 Blog.exists?(id) && Role.exists?(
		 		blog_id: id, 
		 		user_id: self.id, 
		 		active: 1)
			
	end

	def has_open_invites?
		Role.exists?(
			user_id: self.id,
			active: 0)
	end

	def open_invites_count 
		Role.where(
			user_id: self.id,
			active: 0).count
	end

	def open_invites
		Role.where(
			user_id: self.id,
			active: 0)
	end

	def current_blog
		# we need to grab current blog here
		# something like Blog.find(self.current_blog_id)
		# validate that you still have permissions, if not set to nil
		if is_blog_member?
		 	Blog.find(self.current_blog_id)
		else
			update_attribute(:current_blog_id, nil) if self.current_blog_id!=nil
			return nil
		end
	end
end
