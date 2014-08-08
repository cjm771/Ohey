class Post < ActiveRecord::Base
  belongs_to :blog
  belongs_to :user
  extend FriendlyId
    friendly_id :slug_candidates, use: :slugged


  validates :title, presence: true
  before_validation :default_values
  before_save :default_values

  def default_values
   	self.title = "An Untitled Post" if self.title==nil	 
   	self.published = 0 if self.published==nil
  end

  def slug_candidates
    [
      :title,
      [:title, :id]
    ]
  end

  def should_generate_new_friendly_id?
    title_changed?
  end


  def empty?
  	self.title=="An Untitled Post" && self.description.blank?
  end

  def author_role
   self.blog.roles.find_by(user_id: self.user)
  end

end
