class UserDeputy < ActiveRecord::Base

  belongs_to :user
  belongs_to :deputy, :class_name => "User", :foreign_key => "deputy_id"
  belongs_to :project

  default_scope -> { order(:prio, :project) }

  validates_uniqueness_of :deputy_id, :scope => [:user_id, :project_id]

end