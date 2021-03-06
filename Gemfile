# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'active_admin_sidebar'
gem 'active_material', github: 'vigetlabs/active_material'
gem 'active_median'
gem 'active_storage_validations'
gem 'activeadmin'
gem 'activerecord-import'
gem 'activerecord-sqlserver-adapter', '~> 5.2.0'
gem 'chartkick'
gem 'chronic'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'devise'
gem 'dotenv-rails'
gem 'google-api-client'
gem 'groupdate'
gem 'haml'
gem "letter_opener"
gem 'makara', '~> 0.4.1'
gem 'mysql2'
gem 'pg'
gem 'rails_db'
gem 'rubyXL'
gem 'tiny_tds', '~> 2.1.0'
gem 'whenever'

group :development, :test do
  gem 'pry'
  gem 'rb-readline'
  # gem 'pry-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13.0'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # tiny_tds and activerecord-sqlserver-adapter gems are needed by only import_helper.rb, which is not really part of the app, it is more for diagnosing/troubleshooting sql server sources
  gem "bixby"
  gem "capistrano", "~> 3.10", require: false
  gem 'capistrano-passenger', require: false
  gem "capistrano-rails", "~> 1.6", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# Some versions of Ubuntu also requires this gem
gem 'tzinfo-data'

gem 'todo_runner', git: 'https://github.com/upenn-libraries/todo_runner.git', tag: 'v0.4.2'
