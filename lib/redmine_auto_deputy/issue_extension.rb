module RedmineAutoDeputy::IssueExtension
  extend ActiveSupport::Concern

  included do
    before_save :check_assigned_user_availability,  if: :assigned_to_id_changed?
  end

  def check_assigned_user_availability
    return if self.assigned_to.nil?

    check_date = self.due_date || Time.now.to_date

    if self.assigned_to.available_at?(check_date)
      return true
    else # => need to assign someone else
      deputy = self.assigned_to.find_deputy(project_id: self.project_id, date: check_date)
      if deputy
      else
        self.errors.add(:assigned_to, "cant be assigned to ...")
      end
    end
  end

end