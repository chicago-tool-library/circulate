require "test_helper"

class VersionConsistencyTest < ActiveSupport::TestCase
  def parse_tool_versions
    Rails.root.join(".tool-versions").readlines.each_with_object({}) do |line, h|
      tool, version = line.split(" ")
      h[tool] = version
      h
    end
  end
  # Heroku buildpack reads from package.json
  # asdf reads from .tool-versions
  test "node and yarn versions match between package.json and .tool-versions" do
    tool_versions = parse_tool_versions
    package_json = JSON.parse(Rails.root.join("package.json").read)

    assert_equal tool_versions["yarn"].split(".").take(2), package_json["engines"]["yarn"].split(".").take(2), "major and minor yarn version match"
    assert_equal tool_versions["nodejs"].split(".").take(1), package_json["engines"]["node"].split(".").take(1), "major node version matches"
  end

  # Heroku buildpack reads from Gemfile
  # asdf reads from .tool-versions
  # nix reads from .ruby-version
  test "ruby version matches between Gemfile, .ruby-version, and .tool-versions" do
    tool_versions = parse_tool_versions
    gemfile_version = Bundler::Definition.build("Gemfile", nil, {}).ruby_version.versions.first
    ruby_version_file_version = Rails.root.join(".ruby-version").read.split("-").last.chomp

    assert_equal tool_versions["ruby"], ruby_version_file_version
    assert_equal tool_versions["ruby"], gemfile_version
  end
end
