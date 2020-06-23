source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.0"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", ">= 4.0.0.rc.3"

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem "devise"
gem "audited", github: "bonekost/audited"
gem "turbolinks_render"
gem "money-rails"
gem "mjml-rails", github: "jim/mjml-rails", branch: "webpacker"
gem "pagy"
gem "pg_search"
gem "activerecord-postgres_enum"
gem "scenic"
gem "reverse_markdown"
gem "http"

gem "square.rb"
gem "aws-sdk-s3", require: false
gem "sentry-raven"
gem "omniauth-google-oauth2"
gem 'omniauth-rails_csrf_protection', '~> 0.1'

gem "image_processing", "~> 1.2"
gem "mini_magick"

gem "barnes"
gem "sucker_punch"
gem "dotenv-rails"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.1", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "standard"
  gem "factory_bot_rails"
  gem "spy"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen"
  gem "solargraph"
  gem "active_storage_log_suppressor", path: "gems/active_storage_log_suppressor"
  gem "lefthook"
end

group :production do
  gem "skylight"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "minitest-ci"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
