class UserDeputy < ActiveRecord::Base

  belongs_to :user
  belongs_to :deputy, :class_name => "User", :foreign_key => "deputy_id"
  belongs_to :project

  default_scope -> { order('`user_deputies`.`project_id` DESC', :prio) }
  scope :with_projects, -> { unscoped.order('projects.name ASC', :prio).joins(:project).where.not(project_id: nil) }
  scope :without_projects, -> { unscoped.order(:prio).where(project_id: nil) }

  validates_presence_of :user_id, :deputy_id
  validates_uniqueness_of :deputy, :scope => [:user, :project]

  acts_as_list column: :prio, scope: :project

  def enable!
    self.update_attributes(disabled: false, disabled_at: nil)
  end

  def disable!
    self.update_attributes(disabled: true, disabled_at: Time.now)
  end

end