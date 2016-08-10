ENV['RAILS_ENV'] ||= 'test'
# Use SimpleCov
require 'simplecov'
SimpleCov.start do
   add_filter 'spec/'
end

# Loading rails environment
require File.expand_path("../../../../config/environment", __FILE__)
require 'rspec/rails'

# Force using test db connection for test env
db_config = YAML.load(File.open("#{Rails.root}/config/database.yml").read)['test']
ActiveRecord::Base.establish_connection(db_config)

# Loading relevant Files from lib/app
require File.expand_path("../../lib/redmine_auto_deputy.rb", __FILE__)
require File.expand_path("../../app/controllers/user_deputies_controller.rb", __FILE__)
require File.expand_path("../../app/models/user_deputy.rb", __FILE__)

Rails.application.config.paths['app/views'].unshift(File.expand_path("../../app/views", __FILE__))

# Extend test suite
require "pry"
require "factory_girl"

Rails.application.config.after_initialize do
  Rails.application.config.i18n.load_path += Dir[File.expand_path("../config/locales/*.yml", __FILE__)]

  User.send(:include, RedmineAutoDeputy::UserAvailabilityExtension) unless User.included_modules.include?(RedmineAutoDeputy::UserAvailabilityExtension)
  User.send(:include, RedmineAutoDeputy::UserDeputyExtension) unless User.included_modules.include?(RedmineAutoDeputy::UserDeputyExtension)
  Issue.send(:include, RedmineAutoDeputy::IssueExtension) unless Issue.included_modules.include?(RedmineAutoDeputy::IssueExtension)
  Project.send(:include, RedmineAutoDeputy::ProjectExtension) unless Project.included_modules.include?(RedmineAutoDeputy::ProjectExtension)
end

# include and load factories
RSpec.configure { |config| config.include FactoryGirl::Syntax::Methods }
Dir.glob(File.expand_path("../factories/*.rb", __FILE__)).each {|factory_rb| require factory_rb }

require 'capybara/rails'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end
end
