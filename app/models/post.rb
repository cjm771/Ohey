class Post < ActiveRecord::Base
  belongs_to :blog
  belongs_to :user

  validates :title, presence: true

  before_validation :default_values
  before_save :default_values

  def default_values
   	self.title = "An Untitled Post" if self.title==nil	 
   	self.published = 0 if self.published==nil
  end

  def empty?
  	self.title=="An Untitled Post" && self.description.blank?
  end

end
