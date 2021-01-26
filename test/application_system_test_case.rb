require "test_helper"

# The webdrivers gem doesn't work properly for folks using docker-compose
require "webdrivers/chromedriver" unless ENV["DOCKER"]

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

Capybara.register_driver(:headless_chrome) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {args: %w[headless disable-gpu]}
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.register_driver :headless_chrome_in_container do |app|
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub",
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {args: %w[headless disable-gpu window-size=1400x1800]}
    )
end

Capybara.register_driver :chrome_in_container do |app|
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub",
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {args: %w[window-size=1400x1800]}
    )
end

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driver = ENV["HEADLESS"] ? :headless_chrome : :chrome
  driven_by :selenium, using: driver, screen_size: [1400, 1800]

  setup do
    if ENV["DOCKER"]
      Capybara.javascript_driver = ENV["HEADLESS"] == "true" ? :headless_chrome_in_container : :chrome_in_container
      Capybara.current_driver = Capybara.javascript_driver
      Capybara.server_host = "0.0.0.0"
      Capybara.server_port = 4000
      Capybara.app_host = "http://example.com:4000"
    end
  end

  include Warden::Test::Helpers
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def fail_on_js_error(error)
    return false if /the server responded with a status of 422/.match?(error.message)
    error.level == "SEVERE"
  end

  teardown do
    errors = page.driver.browser.manage.logs.get(:browser)
    fail = false
    if errors.present?
      errors.each do |error|
        warn "JS console (#{error.level.downcase}): #{error.message}"
        fail = true if fail_on_js_error(error)
      end
    end

    refute fail, "there were JavaScript errors"
  end

  private

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
end
