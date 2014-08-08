class User < ActiveRecord::Base
	has_secure_password
	extend FriendlyId
	  friendly_id :slug_candidates, use: :slugged

	has_many :blogs
	has_many :posts
	has_many :roles, dependent: :destroy
	
	validates :first_name, :last_name, presence: true
	validates :email, presence: true,
					  uniqueness: true,
					  format: {
					  		with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create 
					  }
	before_save :downcase_email
	 validate :is_valid_email?, on: :create
	
	  # for ranking
	  MULTIPLIERS = {
	    recent_post: 4,
	    active_user_on_blogs: 3,
	    amount_of_posts_made: 3,
	    recent_blog: 2,
	    amount_of_blogs: 1
	  }


	 def slug_candidates
	    [
	      :full_name,
	      [:full_name, :id]
	    ]
  	end

	def should_generate_new_friendly_id?
    	first_name_changed? || last_name_changed?
  	end

	def downcase_email
		self.email =  email.downcase
	end
	def generate_password_reset_token!
		update_attribute(:password_reset_token, SecureRandom.urlsafe_base64(48))
	end

	def is_valid_email? 
		 return unless errors.blank?
		if !User::is_valid_email? self.email
			errors.add :email, "The email you entered is not valid."
		end
	end
	
	def self.is_valid_email? email

    	 response = HTTP.get "https://api:pubkey-6b5o0r4clsvspjv0m2cc87shki3o1fg8"\
"@api.mailgun.net/v2/address/validate", :params =>{ :address => email }
		json = JSON.parse(response)
		puts json
		if (json["is_valid"]!=nil)
			 json["is_valid"]
		else
			false
		end
	end

	 def self.ranked_users
	    @users = User.all
	    @ranks = {};
	    @sorted_users = @users.sort_by do |u|
	      roles = Role.where(:user_id => u.id, :active => 1)
	      posts = Post.where(:user_id => u.id, :published => true)
	      blogs = Blog.where(:user_id => u.id)
	      last_5_posts = Post.last(5)
	      rank = 0
	      # recent post
	      intersection = posts & last_5_posts;
	      rank += self::MULTIPLIERS[:recent_post] * intersection.count
	      puts rank
	      # active users
	      rank += self::MULTIPLIERS[:active_user_on_blogs] * roles.count
	      puts rank
	      # amount of posts
	      rank +=  self::MULTIPLIERS[:amount_of_posts_made] * posts.count    
	      # recent blog
	       intersection = blogs & last_5_posts;
	       rank += self::MULTIPLIERS[:recent_blog] * intersection.count
	      # amount of blogs
	      puts u.full_name + " = "+rank.to_s
	      rank += self::MULTIPLIERS[:amount_of_blogs] *blogs.count
	      rank
	    end

	    @sorted_users.reverse
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

	def can_edit_role? role
		blog = role.blog
		editorRole = self.get_role blog
		if role && blog
			editorRole && (editorRole.role>role.role || ( editorRole==role && role!=Role::CREATOR))
		else
			false
		end
	end

	def can_edit_post? post
		if post.user
			authorRole = post.user.get_role post.blog
			editorRole = self.get_role post.blog
			if authorRole==nil && editorRole.role>=Role::MODERATOR 
				# probably means author was deleted so moderators and contributors can edit these
				return true 
			end
			authorRole && editorRole && (editorRole.role>authorRole.role || self.is_creator?(post.blog) || editorRole==authorRole)
		else
			true
		end
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

	def get_role blog
		if is_blog_member? blog.id
			Role.where(blog_id: blog.id, user_id: self.id, active: 1).first
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
			email: self.email,
			active: 0)

	end

	def open_invites_count 
		Role.where(
			email: self.email,
			active: 0).count 
	
	end

	def open_invites
		Role.where(
			email: self.email,
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
