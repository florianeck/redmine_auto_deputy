Redmine::Plugin.register :redmine_auto_deputy do
  name 'AutoDeuputy'
  author 'Florian Eck for akquinet'
  description 'Automatically assign deputy users if the inital user assigned to an issue is not available'
  version '0.1.0'
end

require "redmine_auto_deputy"

Rails.application.config.after_initialize do
  #TimeEntry.send(:include, TimeEntryHierarchyCf::ProjectIssueCustomFields)
end