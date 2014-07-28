class Role < ActiveRecord::Base

  belongs_to :user
  belongs_to :blog

  # can only create and edit their own
  CONTRIBUTOR = 0;
  # can edit contributor posts
  # can create and edit their own
  MODERATOR = 1;
  # can edit contributor and moderator posts
  # can create and edit their own
  # can invite moderators / contributors
  # can remove/change role of moderator, contributor
  # can edit blog info
  CREATOR = 2;

  ROLE_TEXT = {
  	0 => "Contributor",
  	1 => "Moderator",
  	2 => "Creator"
  }
end
