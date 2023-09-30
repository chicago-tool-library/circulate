# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.4"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma"

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# The latest release doesn't include the test helpers. Using this branch includes those.
# See: https://github.com/ErwinM/acts_as_tenant/issues/215#issuecomment-552076674
gem "activerecord-postgres_enum"
gem "acts_as_tenant"
gem "audited", github: "simmerz/audited"
gem "devise"
gem "http"
gem "mjml-rails" # , github: "jim/mjml-rails", branch: "webpacker"
gem "money-rails"
gem "pagy"
gem "pg_search"
gem "pundit"
gem "reverse_markdown"
gem "scenic"
gem "store_model"
gem "translation"
gem "turbolinks_render"

gem "aws-sdk-s3", require: false
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "sentry-raven"
gem "square.rb"

gem "image_processing", "~> 1.12"
gem "mini_magick"

gem "appsignal"
gem "barnes"
gem "dotenv-rails"
gem "sucker_punch"

gem "chronic"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.1", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "letter_opener"
  gem "rubocop", ">= 1.25.1", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rails", require: false
  gem "spy"
  gem "standard"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "active_storage_log_suppressor", path: "gems/active_storage_log_suppressor"
  gem "erb_lint", "~> 0.1.1"
  gem "lefthook"
  gem "listen"
  gem "solargraph"
  gem "web-console", ">= 3.3.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "minitest", "5.15.0"
  gem "minitest-ci"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "jsbundling-rails", "~> 1.2"

gem "cssbundling-rails", "~> 1.3"
