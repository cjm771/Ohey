class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :roles, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :title, length: {minimum: 2}, allow_blank: true

  before_save :default_values

  def default_values
   	self.title = "#{user.first_name}'s Blog" if self.title==""
  end

end
