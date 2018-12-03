module RedmineAutoDeputy::UserDeputyExtension
  extend ActiveSupport::Concern

  included do
    has_many :user_deputies, class_name: 'UserDeputy', foreign_key: :user_id
    has_many :akq_memberships, class_name: 'Member', foreign_key: :user_id
    has_many :roles, through: :akq_memberships

    scope :with_deputy_permission, -> (permission_name) {
      joins(:roles)
      .where("member_roles.role_id" => RedmineAutoDeputy::UserDeputyExtension.roles_for(permission_name).map(&:id)).group(:id)
    }
  end

  def self.roles_for(permission_name)
    Role.where("roles.permissions LIKE '%#{permission_name}%'")
  end

  def find_deputy(project_id: nil, already_tried: [self.id], date: Time.now.to_date)
    # if project id given, first check if the given project allows user to have deputy
    return if (project_id.present? && !can_have_deputies_for_project?(project_id))

    deputies = user_deputies.where(project_id: [nil, project_id].uniq ).where.not(deputy_id: already_tried)

    deputies_available = []

    deputies.each do |d|
      if d.deputy.available_at?(date) && d.deputy.can_be_deputy_for_project?(project_id)
        if d.disabled?
          d.enable!
        end

        deputies_available << d
      elsif !d.deputy.can_be_deputy_for_project?(project_id) && !d.disabled?
        d.disable!
      end
    end

    if deputies_available.any?
      return deputies_available.first
    elsif deputies.any? # => check next level of deputies
      return deputies.map {|d| d.deputy.find_deputy(project_id: project_id, already_tried: already_tried+deputies.pluck(:deputy_id), date: date) }.flatten.first
    else
      return nil
    end
  end

  def projects_with_have_deputies_permission
    Project.where(Project.allowed_to_condition(self, :have_deputies)).order(:name)
  end

  def can_have_deputies_for_project?(project_id)
    projects_with_have_deputies_permission.pluck(:id).include?(project_id)
  end

  def projects_with_be_deputy_permission
    Project.where(Project.allowed_to_condition(self, :be_deputy)).order(:name)
  end

  def can_be_deputy_for_project?(project_id)
    project_id.nil? || projects_with_be_deputy_permission.pluck(:id).include?(project_id)
  end

end