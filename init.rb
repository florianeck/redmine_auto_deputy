Redmine::Plugin.register :redmine_auto_deputy do
  name 'AutoDeputy'
  author 'Florian Eck for akquinet'
  description 'Automatically assign deputy users if the inital user assigned to an issue is not available'
  version '0.1.0'

  menu :top_menu, :deputies, { :controller => 'user_deputies', :action => 'index' }, :caption => :deputies, if: Proc.new { User.current.logged? && User.current.allowed_to_globally?(:have_deputies) }, :html => {:class => 'icon icon-time'}

  Redmine::AccessControl.map do |map|
    map.project_module :user_deputies do |pmap|
      pmap.permission :edit_deputies, { user_deputies: [:index, :move_up, :move_down, :create, :delete, :set_availabilities] }, global: true
      pmap.permission :have_deputies, { user_deputies: [:index, :move_up, :move_down, :create, :delete, :set_availabilities] }
      pmap.permission :be_deputy,     { user_deputies: [] }
    end
  end



end

require "redmine_auto_deputy"

Rails.application.config.after_initialize do
  User.send(:include, RedmineAutoDeputy::UserAvailabilityExtension)
  User.send(:include, RedmineAutoDeputy::UserDeputyExtension)
  Issue.send(:include, RedmineAutoDeputy::IssueExtension)
end