module RedmineAutoDeputy::ProjectExtension
  extend ActiveSupport::Concern

  def possible_project_id_for_deputies(user, current_project_id = nil)
    if current_project_id && current_project_id
      deputy_entry = UserDeputy.where(user_id: user.id, disabled: false, project_id: self.id, projects_inherit: true).first
    else
      deputy_entry = UserDeputy.where(user_id: user.id, disabled: false, project_id: self.id).first
    end

    # Project has its own deputy
    if deputy_entry.present?
      return self.id
    elsif self.parent
      self.parent.possible_project_id_for_deputies(user, current_project_id || self.id)
    end
  end

end