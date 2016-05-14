module RedmineAutoDeputy::UserDeputyExtension
  extend ActiveSupport::Concern

  included do
    has_many :user_deputies, class_name: 'UserDeputy', foreign_key: :user_id
  end

  def find_deputy(project_id: nil, already_tried: [], date: Time.now.to_date)
    deputies = user_deputies.where(project_id: [nil, project_id].uniq ).where.not(deputy_id: already_tried)
    deputies_available = deputies.select {|d| d.deputy.available_at?(date) }

    if deputies_available.any?
      return deputies_available.first
    elsif deputies.any? # => check next level of deputies
      return deputies.map {|d| d.find_deputy(project_id: project_id, already_tried: already_tried+deputies.pluck(:deputy_id), date: date) }.flatten.first
    else
      return nil
    end
  end

end