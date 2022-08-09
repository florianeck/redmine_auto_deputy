source 'https://rubygems.org'

gem 'acts_as_list', '< 0.9.0'

# these are required in order to run the specs with 'rspec-rails' in EasyRedmine
# use RAILS_ENV=test in order to run the specs via 'rspec' command
# please note: the gems need to be exactly the same versions as given in your host redmine application Gemfile
if ENV['RAILS_ENV'] == 'test'
  gem 'rails', '4.2.5'
  gem 'activesupport'
  gem 'actionpack-xml_parser'
  gem 'mysql2', '~> 0.3.11'
  gem 'rack-openid'
  gem 'protected_attributes'
  gem 'request_store', '1.0.5'
end

group :development, :test do
  gem "pry"
end

group :test do
  gem "simplecov", "~> 0.17.0", require: true
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'capybara', '~> 3.25.0'
  gem 'database_cleaner'
  gem 'timecop'
end






