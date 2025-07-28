source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 8.0.1"

# Since Rails 7 sprockets is optional; we still use it so we need to depend on
# the gem explicitly
gem "sprockets-rails", require: "sprockets/railtie"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.13"

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
gem "scenic"
gem "reverse_markdown", "~>3.0"
gem "http"
gem "translation"
gem "store_model"
gem "lograge"
gem "acts_as_list"
gem "finite_machine"
gem "ransack"

gem "square.rb"
gem "aws-sdk-s3", require: false
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

# Calendar syncing
gem "googleauth"

gem "image_processing", "~> 1.14", require: "image_processing/vips"
gem "mini_magick"

gem "barnes"
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
  # Temporarily pinning standard-rails until a release after 1.1.0 is cut
  gem "standard-rails"
  gem "factory_bot_rails"
  gem "spy"
  gem "letter_opener"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen"
  gem "lefthook"
  gem "erb_lint", "~> 0.9.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "minitest", "5.25.5"
  gem "capybara", ">= 2.15"
  gem "capybara-playwright-driver"
  gem "rails-controller-testing"
  gem "timecop"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "jsbundling-rails", "~> 1.3"

gem "cssbundling-rails", "~> 1.4"

gem "twilio-ruby", "~> 7.7"

gem "ahoy_matey", "~> 5.4"

gem "good_job", "~> 4.11"

gem "blazer", "~> 3.3"

gem "acts-as-taggable-on", "~> 12.0"
