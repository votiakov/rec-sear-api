source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgres as the database for Active Record
gem 'pg'
gem 'activerecord-postgis-adapter'

gem 'sidekiq'
gem 'whenever', :require => false

gem 'redis', '~> 3.0'
gem 'hiredis'
gem 'redis-namespace'

gem 'rails-i18n'

gem 'puma', '>= 3.6.2'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', :require => 'rack/cors'

gem 'cancancan'

# For ENV variables
gem 'figaro'

gem 'paper_trail', '~> 5.2.3'


# ActiveRecord related
gem 'enumerize'
gem 'immigrant'
gem 'symbolize'
# gem 'squeel', '~> 1.2.3'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'normalizr'
gem 'hashie'
gem 'annotate', '~> 2.7.1'
gem 'email_validator'
gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'
gem 'micro_token'
gem 'carrierwave'

gem 'active_model_serializers', '~> 0.10.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem "bullet"

  gem 'factory_girl_rails'

  gem 'railroady'
end

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rails-db'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.2'
  gem 'capistrano-sidekiq' , github: 'seuros/capistrano-sidekiq'
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  gem "capistrano-db-tasks", '~> 0.4', require: false

  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-doc'
  # gem 'thin'
  gem "awesome_print", require:"ap"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
