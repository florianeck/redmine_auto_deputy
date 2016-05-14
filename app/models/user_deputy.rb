class UserDeputy < ActiveRecord::Base

  belongs_to :user
  belongs_to :deputy, :class_name => "User", :foreign_key => "deputy_id"
  belongs_to :project

  default_scope -> { order(:prio, :project_id) }

  validates_uniqueness_of :deputy, :scope => [:user, :project]

  acts_as_list column: :prio, scope: :project

end