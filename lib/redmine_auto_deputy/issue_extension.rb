module RedmineAutoDeputy::IssueExtension
  extend ActiveSupport::Concern

  included do
    before_save :check_assigned_user_availability,  if: :assigned_to_id_changed?
  end

  private
  def check_assigned_user_availability
    return if self.assigned_to.nil? || self.assigned_to == User.current

    check_date = [self.due_date, Time.now.to_date].compact.max

    original_assigned = self.assigned_to

    if self.assigned_to.available_at?(check_date)
      return true
    else # => need to assign someone else
      user_deputy = self.assigned_to.find_deputy(project_id: self.project_id, date: check_date)
      if user_deputy
        self.assigned_to = user_deputy.deputy

        self.init_journal(user_deputy.deputy)
        self.current_journal.notes = I18n.t('issue_assigned_to_changed', new_name: self.assigned_to.name, original_name: original_assigned.name)
        return true
      else
        self.errors.add(:assigned_to, I18n.t('activerecord.errors.issue.cant_be_assigned_due_to_unavailability', user_name: self.assigned_to.name, date: check_date.to_s))
        return false
      end
    end
  end

end