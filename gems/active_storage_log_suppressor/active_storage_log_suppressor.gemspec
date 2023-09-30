# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_storage_log_suppressor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "active_storage_log_suppressor"
  spec.version = ActiveStorageLogSuppressor::VERSION
  spec.authors = ["Jim Benton"]
  spec.email = ["jim@autonomousmachine.com"]
  spec.homepage = "https://github.com/jim/active_storate_log_suppressor"
  spec.summary = "Silences ActiveStorage requests in development mode."
  spec.description = "Silences ActiveStorage requests in development mode."
  spec.license = "MIT"

  spec.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0.0"
end
