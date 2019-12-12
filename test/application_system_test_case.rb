require "test_helper"

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

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driver = ENV["HEADLESS"] ? :headless_chrome : :chrome
  driven_by :selenium, using: driver, screen_size: [1400, 1400]

  include Warden::Test::Helpers
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  private

  def sign_in_as_admin
    @user = FactoryBot.create(:user)
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

    html = delivered_mail.body.parts[0].body.to_s
    text = delivered_mail.body.parts[1].body.to_s
    yield html, text
  end
end
