module RedmineAutoDeputy::IssueExtension
  extend ActiveSupport::Concern

  included do
    before_save :check_assigned_user_availability,  if: :assigned_to_id_changed?
  end

  private
  def check_assigned_user_availability
    return if self.assigned_to.nil?

    check_date = self.due_date || Time.now.to_date

    if self.assigned_to.available_at?(check_date)
      return true
    else # => need to assign someone else
      deputy = self.assigned_to.find_deputy(project_id: self.project_id, date: check_date)
      if deputy
        self.assigned_to = deputy
        return true
      else
        self.errors.add(:assigned_to, I18n.t('activerecord.errors.issue.cant_be_assigned_due_to_unavailability', user_name: self.assigned_to.name, date: check_date.to_s))
        return false
      end
    end
  end

end