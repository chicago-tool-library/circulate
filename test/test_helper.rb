ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "spy/integration"
require "minitest/mock"

require "helpers/return_values"
require "helpers/ensure_request_tenant"

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

  # Postgres stores time at microsecond precision, while Ruby's Time classes
  # operate at nanosecond precision. To simplify comparison, this helper
  # truncates the nanosecond portion of the expected argument.
  #
  # While it is not required for the equality check to pass, this also converts
  # the expected argument to a TimeWithZone, which is what ActiveRecord
  # timestamps will be. This makes the output on failure a little cleaner as
  # the to_s representations will line up.
  #
  # See: https://stackoverflow.com/questions/57703148/rails-timewithzone-doesnt-match
  def assert_timestamp_equal(expected, subject)
    assert_equal expected.in_time_zone.floor(6), subject, "expected timestamps to match to within microsecond precision"
  end

  class << self
    def env_tags
      @env_tags ||= ENV.fetch("TAGS", "").split
    end

    def test(subject, *tags, &block)
      if tags.include?(:remote) && !env_tags.include?("remote")
        super subject do
          skip "Skipping remote test"
        end
      else
        super(subject, &block)
      end
    end
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
