# Use SimpleCov
require 'simplecov'
SimpleCov.start

# Loading rails environment
require File.expand_path("../../../../config/environment", __FILE__)

# Force using test db connection for test env
db_config = YAML.load(File.open("#{Rails.root}/config/database.yml").read)['test']
ActiveRecord::Base.establish_connection(db_config)

# Loading relevant Files from lib/
require File.expand_path("../../lib/redmine_auto_deputy.rb", __FILE__)

# Extend test suite
require "pry"

# include and load factories
RSpec.configure { |config| config.include FactoryGirl::Syntax::Methods }
Dir.glob(File.expand_path("../factories/*.rb", __FILE__)).each {|factory_rb| require factory_rb }
