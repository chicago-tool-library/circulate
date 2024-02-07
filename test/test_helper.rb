ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "spy/integration"
require "minitest/mock"

require "helpers/return_values"
require "helpers/ensure_request_tenant"

# Explicit require means the plugin is available when tests are evaluated;
# otherwise, the plugin isn't loaded until later.
require "minitest/tags_plugin"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods

  def assert_size(expected, subject)
    assert_equal expected, subject.size, "wrong size; got #{subject.size} instead of #{expected}"
  end

  setup do
    ActsAsTenant.test_tenant = libraries(:chicago_tool_library)
  end

  teardown do
    ActsAsTenant.test_tenant = nil
  end
end

class ActionDispatch::IntegrationTest
  # @note Just to make tests pass for now...
  include EnsureRequestTenant
end
