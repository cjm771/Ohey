class Role < ActiveRecord::Base

  belongs_to :user
  belongs_to :blog

  validates :email, presence: true,
            format: {
                with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create 
            }

  validate :already_member_or_invited, on: :create

  # can only create and edit their own
  CONTRIBUTOR = 0
  # can edit contributor posts
  # can create and edit their own
  MODERATOR = 1
  # can edit contributor and moderator posts
  # can create and edit their own
  # can invite moderators / contributors
  # can remove/change role of moderator, contributor
  # can edit blog info
  CREATOR = 2

  DENIED = -1
  INVITED = 0
  ACTIVE = 1


  ROLE_TEXT = {
  	0 => "Contributor",
  	1 => "Moderator",
  	2 => "Creator"
  }
  private 
  def already_member_or_invited
    user = User.find_by :email => self.email
    if (Role.exists?(:blog_id => self.blog.id, :email => self.email ) ||
        (user && Role.exists?(:blog_id => self.blog.id, :user_id =>  user.id)))
           errors.add :email, "is already a member of this blog or has been invited."
    end
  end
end
