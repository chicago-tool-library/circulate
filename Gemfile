source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 7.1.3"

# Since Rails 7 sprockets is optional; we still use it so we need to depend on
# the gem explicitly
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.12"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# The latest release doesn't include the test helpers. Using this branch includes those.
# See: https://github.com/ErwinM/acts_as_tenant/issues/215#issuecomment-552076674
gem "acts_as_tenant"
gem "devise"
gem "pundit"
gem "audited"
gem "money-rails"
gem "mjml-rails" # , github: "jim/mjml-rails", branch: "webpacker"
gem "pagy"
gem "pg_search"
gem "activerecord-postgres_enum"
gem "scenic"
gem "reverse_markdown"
gem "http"
gem "translation"
gem "store_model"
gem "lograge"
gem "acts_as_list"
gem "finite_machine"

gem "square.rb"
gem "aws-sdk-s3", require: false
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

# Calendar syncing
gem "googleauth"

gem "image_processing", "~> 1.12"
gem "mini_magick"

gem "barnes"
gem "sucker_punch"
gem "dotenv"
gem "appsignal"

gem "chronic"
gem "turbo-rails"
gem "stimulus-rails"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.1", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "standard"
  gem "standard-rails", "~> 1.0.2"
  gem "factory_bot_rails"
  gem "spy"
  gem "letter_opener"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen"
  gem "solargraph"
  gem "solargraph-rails"
  gem "solargraph-standardrb"
  gem "lefthook"
  gem "erb_lint", "~> 0.5.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "minitest", "5.23.1"
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "rails-controller-testing"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "jsbundling-rails", "~> 1.3"

gem "cssbundling-rails", "~> 1.4"

gem "twilio-ruby", "~> 7.1"

gem "ahoy_matey", "~> 5.1"

gem "good_job", "~> 3.29"
