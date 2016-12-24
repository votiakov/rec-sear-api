# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

# require 'simplecov'
# SimpleCov.start 'rails' do
#   add_group 'Services', '/app/services/'
#   add_group 'Serializers', '/app/serializers/'
#   add_group 'Workers', '/app/workers/'
#   add_group 'Uploaders', '/app/uploaders/'
# end

require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'database_cleaner'
require 'shoulda/matchers'
require 'shoulda-callback-matchers'
require 'rspec/expectations'
require "webrat"

# features related
require 'rack'
# require 'capybara'
# require 'capybara/rspec'
# require 'capybara/angular'

# Require all support files
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Webrat.configure do |config|
  config.mode = :rails
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include Normalizr::RSpec::Matcher
  config.include FactoryGirl::Syntax::Methods
  # config.include Capybara::Angular::DSL,        type: :feature
  # config.include ::Angular::DSL,                type: :feature
  # config.include Features::SessionHelpers,      type: :feature
  # config.include Features::GestureHelpers,      type: :feature

  config.filter_run :focus

  # Database maintenace
  config.use_transactional_fixtures = false
  config.around(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.infer_spec_type_from_file_location!
end

# features related
# Capybara.register_driver :selenium_chrome do |app|
#   Capybara::Selenium::Driver.new(app, :browser => :chrome)
# end

# Capybara.run_server = false
# Capybara.app_host = 'http://localhost:9000'
# Capybara.default_selector = :css
# Capybara.default_max_wait_time = 15
# Capybara.ignore_hidden_elements = false
# Capybara.javascript_driver = :selenium_chrome
# Capybara.current_driver = :selenium_chrome
# Capybara.page.driver.browser.manage.window.resize_to(1400,800)
