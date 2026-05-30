require "test_helper"

class AdminHelperTest < ActionView::TestCase
  setup do
  end

  test "flash_message returns nothing when there is no matching flash for the given key" do
    flash.now[:notice] = "This is a notice."

    result = flash_message(:success)

    assert_nil result
  end

  test "flash_message returns a closable toast message for the given key" do
    message = "This is a notice."
    flash.now[:notice] = message

    result = flash_message(:notice)

    refute_nil result
    assert_includes result, message
    assert_includes result, "toast-notice"
    assert_includes result, "btn-clear"
  end

  test "flash_message returns a closable toast message for the given key with an overridable type" do
    message = "This is a notice."
    flash.now[:notice] = message

    result = flash_message(:notice, :alert)

    refute_nil result
    assert_includes result, message
    assert_includes result, "toast-alert"
    assert_includes result, "btn-clear"
  end

  test "flash_message_html returns a closable toast message for the given message and flash type" do
    message = "This is another message."
    result = flash_message_html(message, :notice)

    refute_nil result
    assert_includes result, message
    assert_includes result, "toast-notice"
    assert_includes result, "btn-clear"

    result = flash_message_html(message, :success)

    refute_nil result
    assert_includes result, message
    assert_includes result, "toast-success"
    assert_includes result, "btn-clear"
  end
end
