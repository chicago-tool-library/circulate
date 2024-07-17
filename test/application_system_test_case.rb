require "test_helper"
require "test_helpers/stdout_helpers"

Capybara.default_max_wait_time = 5

# Backported from Rails 6.1
Capybara.add_selector :rich_text_area do
  label "rich-text area"
  xpath do |locator|
    if locator.nil?
      XPath.descendant(:"trix-editor")
    else
      input_located_by_name = XPath.anywhere(:input).where(XPath.attr(:name) == locator).attr(:id)

      XPath.descendant(:"trix-editor").where \
        XPath.attr(:id).equals(locator) |
          XPath.attr(:placeholder).equals(locator) |
          XPath.attr(:"aria-label").equals(locator) |
          XPath.attr(:input).equals(input_located_by_name)
    end
  end
end

Capybara.register_driver :headed_chrome do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser: :chrome,
    headless: false
  )
end

Capybara.register_driver :headless_chrome do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser: :chrome,
    headless: true,
    # We only use this env var for the Nix dev environment. For other platforms
    # we can let playwright use its own downloaded browser.
    executablePath: ENV.fetch("PLAYWRIGHT_CHROME_BINARY", nil)
  )
end

# Capybara.register_driver :headless_chrome_in_container do |app|
#   Capybara::Playwright::Driver.new(
#     app,
#     browser: :remote,
#     url: "http://selenium_chrome:4444/wd/hub"
#   )
# end

# Capybara.register_driver :chrome_in_container do |app|
#   Capybara::Selenium::Driver.new(
#     app,
#     browser: :remote,
#     url: "http://selenium_chrome:4444/wd/hub",
#     options: Selenium::WebDriver::Chrome::Options.new.tap do |opts|
#       opts.add_argument "--window-size=1400x1800"
#     end
#   )
# end

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end

if ENV["DOCKER"]
  Capybara.server_host = "0.0.0.0"
  Capybara.server_port = 4000
  Capybara.app_host = "http://example.com:4000"
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driver = if ENV["DOCKER"]
  #   (ENV["HEADLESS"] == "true") ? :headless_chrome_in_container : :chrome_in_container
  # else
  #   (ENV["HEADLESS"] == "true") ? :headless_chrome : nil
  # end

  driver = (ENV["HEADLESS"] == "true") ? :headless_chrome : :headed_chrome
  driven_by driver

  setup do
    ActsAsTenant.test_tenant = libraries(:chicago_tool_library)
    # System tests submit real forms so we can exercise CSRF protection
    ActionController::Base.allow_forgery_protection = true
  end

  include Warden::Test::Helpers
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper
  include StdoutHelpers

  def fail_on_js_error(error)
    return false if /the server responded with a status of 422/.match?(error.message)
    error.level == "SEVERE"
  end

  teardown do
    ActsAsTenant.test_tenant = nil
    ActionController::Base.allow_forgery_protection = false

    # errors = page.driver.browser.logs.get(:browser)
    # fail = false
    # if errors.present?
    #   errors.each do |error|
    #     if fail_on_js_error(error)
    #       warn "JS console (#{error.level.downcase}): #{error.message}"
    #       fail = true
    #     end
    #   end
    # end

    # refute fail, "there were JavaScript errors"
  end

  private

  def ignore_js_errors(reason: "I know what I am doing")
    # Rails.logger.info("Ignored JS error because: #{reason}")
    yield if block_given?
    # page.driver.browser.logs.get(:browser)
  end

  def sign_in_as_admin
    @user = FactoryBot.create(:user, role: "admin")
    login_as(@user, scope: :user)
  end

  def audited_as_admin(&block)
    Audited.audit_class.as_user(@user) do
      yield
    end
  end

  def fill_in_rich_text_area(locator = nil, with:)
    find(:rich_text_area, locator).execute_script("this.editor.loadHTML(arguments[0])", with.to_s)
  end

  def assert_delivered_email(to:, &block)
    delivered_mail = ActionMailer::Base.deliveries.last
    assert_equal [to], delivered_mail.to

    assert delivered_mail.body.parts.size == 2, "non multipart email was sent!"

    if delivered_mail.attachments.size > 0
      text = delivered_mail.body.parts[0].body.parts[0].body
      html = delivered_mail.body.parts[0].body.parts[1].body
      attachments = delivered_mail.attachments
    else
      html = delivered_mail.body.parts[0].body.to_s
      text = delivered_mail.body.parts[1].body.to_s
      attachments = []
    end
    yield html, text, attachments
  end

  def assert_date_displayed(datetime)
    find("time[datetime='#{datetime.utc}']")
  end

  # Sometimes the Square sandbox site returns a 404 for a little while after being created.
  # This method will check to see if the sandbox page has successfully loaded, and if not,
  # it will reload the page after a short wait.
  def wait_for_square_sandbox_to_load
    attempt = 0
    loop do
      page.find("p", text: "order_id")
      return
    rescue Capybara::ElementNotFound
      attempt = 1
      if attempt > 2
        raise
      end
      puts "sandbox page didn't load, trying again"
      sleep 1
      refresh
    end
  end

  # The GH action runners are _slow_ and things like image generation or
  # MJML rendering will easily timeout unless given a lot of breathing room.
  def slow_op_wait_time
    ENV["GITHUB_ACTIONS"] ? 30 : 10
  end
end
