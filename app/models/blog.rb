class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :roles, dependent: :destroy
  has_many :posts, dependent: :destroy
  extend FriendlyId
	  friendly_id :slug_candidates, use: :slugged

  validates :title, length: {minimum: 2}, allow_blank: true

  before_save :default_values

  # for ranking
  MULTIPLIERS = {
    recent_post: 4,
    active_users: 3,
    amount_of_posts: 3,
    recent_blog: 2
  }

  def default_values
   	self.title = "#{user.first_name}'s Blog" if self.title==""
  end

  def active_roles
    self.roles.where("active > ?", 0)
  end

  def self.ranked_blogs
    @blogs = Blog.all
    @sorted_blogs = @blogs.sort_by do |b|
      users = Role.where(:blog_id => b.id)
      posts = Post.where(:blog_id => b.id, :published => true)
      last_5_posts = Post.last(5)
      last_5_blogs = Blog.last(5)
      rank = 0
      # recent post
      intersection = posts & last_5_posts;
      rank += self::MULTIPLIERS[:recent_post] * intersection.count
      puts rank
      # active users
      rank += self::MULTIPLIERS[:active_users] * users.where( :active => 1).count
      puts "amount of users: "+users.where( :active => 1).count.to_s
      puts rank
      # amount of posts
      rank +=  self::MULTIPLIERS[:amount_of_posts] * posts.count
      puts rank     
      # recent blog
       rank += self::MULTIPLIERS[:recent_blog] * (last_5_blogs.include?(b) ? 1 : 0)
       puts b.title.to_s+" = "+rank.to_s
      rank
    end

    @sorted_blogs.reverse
  end

  def published_posts
    self.posts.where(:published => true)
  end

  def should_generate_new_friendly_id?
    title_changed?
  end

  def slug_candidates
    [
      :title,
      [:title, :id]
    ]
  end

end
