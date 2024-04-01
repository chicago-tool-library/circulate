require "test_helper"

class VersionConsistencyTest < ActiveSupport::TestCase
  def parse_tool_versions
    File.readlines(Rails.root.join(".tool-versions")).each_with_object({}) do |line, h|
      tool, version = line.split(" ")
      h[tool] = version
      h
    end
  end
  # Heroku buildpack reads from package.json
  # asdf reads from .tool-versions
  test "node and yarn versions match between package.json and .tool-versions" do
    tool_versions = parse_tool_versions
    package_json = JSON.parse(File.read(Rails.root.join("package.json")))

    assert_equal tool_versions["yarn"], package_json["engines"]["yarn"]
    assert_equal tool_versions["nodejs"], package_json["engines"]["node"]
  end

  # Heroku buildpack reads from Gemfile
  # asdf reads from .tool-versions
  # nix reads from .ruby-version
  test "ruby version matches between Gemfile, .ruby-version, and .tool-versions" do
    tool_versions = parse_tool_versions
    gemfile_version = Bundler::Definition.build("Gemfile", nil, {}).ruby_version.versions.first
    ruby_version_file_version = File.read(Rails.root.join(".ruby-version")).split("-").last.chomp

    assert_equal tool_versions["ruby"], ruby_version_file_version
    assert_equal tool_versions["ruby"], gemfile_version
  end
end
