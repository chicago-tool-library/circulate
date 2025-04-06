ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "spy/integration"
require "minitest/mock"

require "helpers/return_values"
require "helpers/ensure_request_tenant"
require "test_helpers/twilio_helper"
require "test_helpers/open_days_helper"

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
  include OpenDaysHelper

  def assert_size(expected, subject)
    assert_equal expected, subject.size, "wrong size; got #{subject.size} instead of #{expected}"
  end

  setup do
    ActsAsTenant.test_tenant = libraries(:chicago_tool_library)

    BaseTexter.client = TwilioHelper::FakeSMS.new
    TwilioHelper::FakeSMS.messages.clear
  end

  teardown do
    ActsAsTenant.test_tenant = nil

    BaseTexter.client = nil
  end
end

class ActionDispatch::IntegrationTest
  include EnsureRequestTenant

  def assert_enqueued_email(mailer, method, params: {})
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ->(job_arguments) {
      job_mailer, job_method, _delivery, rest = *job_arguments
      assert_equal mailer.to_s, job_mailer
      assert_equal method.to_s, job_method
      assert_equal(params, rest[:params])
    })
  end
end
