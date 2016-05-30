module RedmineAutoDeputy::UserDeputyExtension
  extend ActiveSupport::Concern

  included do
    has_many :user_deputies, class_name: 'UserDeputy', foreign_key: :user_id
    has_many :memberships, class_name: 'Member', foreign_key: :user_id
    has_many :roles, through: :memberships

    scope :with_deputy_permission, -> (permission_name) {
      joins(:roles)
      .where("member_roles.role_id" => RedmineAutoDeputy::UserDeputyExtension.roles_for(permission_name).map(&:id)).group(:id)
    }
  end

  def self.roles_for(permission_name)
    Role.where("`roles`.`permissions` LIKE '%#{permission_name}%'")
  end

  def find_deputy(project_id: nil, already_tried: [self.id], date: Time.now.to_date)
    deputies = user_deputies.where(project_id: [nil, project_id].uniq ).where.not(deputy_id: already_tried)
    deputies_available = deputies.select {|d| d.deputy.available_at?(date) }

    if deputies_available.any?
      return deputies_available.first
    elsif deputies.any? # => check next level of deputies
      return deputies.map {|d| d.deputy.find_deputy(project_id: project_id, already_tried: already_tried+deputies.pluck(:deputy_id), date: date) }.flatten.first
    else
      return nil
    end
  end

end