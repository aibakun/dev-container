source 'https://rubygems.org'

ruby '3.2.3'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 6.4.3'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use bcrypt for password hashing
gem 'bcrypt'

# Use Bootstrap for styling
gem 'bootstrap', '~> 5.3.3'
gem 'jquery-rails'
gem 'sassc-rails'

gem 'brakeman'

# Use bundler-audit to check for vulnerable versions of gems
gem 'bundler-audit'

# Use rubocop for static code analysis
gem 'rubocop', require: false

# Update vulnerable gems
gem 'nokogiri', '>= 1.16.5'
gem 'rails-html-sanitizer', '>= 1.6.1'
gem 'rexml', '>= 3.3.9'
gem 'webrick', '>= 1.8.2'

group :development, :test do
  # Use debugger
  gem 'debug', platforms: %i[mri windows]
end

group :test do
  # Use RSpec for testing
  gem 'rspec-rails'

  # Use FactoryBot for testing
  gem 'factory_bot_rails'

  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end
