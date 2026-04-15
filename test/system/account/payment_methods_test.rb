require "application_system_test_case"

module Account
  class PaymentMethodsTest < ApplicationSystemTestCase
    setup do
      @member = create(:verified_member_with_membership)

      login_as @member.user
    end

    test "viewing payment methods" do
      mock_stripe_checkout = Minitest::Mock.new
      mock_stripe_checkout.expect :sync_payment_methods, nil, [@member.user]

      ignored_payment_method = create(:payment_method, :active)
      active_payment_method = create(:payment_method, :active, user: @member.user)
      expired_payment_method = create(:payment_method, :expired, user: @member.user)
      detached_payment_method = create(:payment_method, :detached, user: @member.user)

      StripeCheckout.stub :build, mock_stripe_checkout do
        visit account_payment_methods_url

        assert_text active_payment_method.last_four
      end

      refute_text ignored_payment_method.last_four
      refute_text expired_payment_method.last_four
      refute_text detached_payment_method.last_four
    end

    # This test is really just confirming that a form is created
    # with the generated stripe intent
    test "creating a payment method" do
      mock_stripe_intent = SecureRandom.hex

      mock_stripe_result = Minitest::Mock.new
      mock_stripe_result.expect :success?, true
      mock_stripe_result.expect :value, mock_stripe_intent

      mock_stripe_checkout = Minitest::Mock.new
      mock_stripe_checkout.expect :sync_payment_methods, nil, [@member.user]
      mock_stripe_checkout.expect :prepare_to_collect_payment_info, mock_stripe_result, [@member.user]

      StripeCheckout.stub :build, mock_stripe_checkout do
        visit account_payment_methods_url
        click_link "Add new payment method"

        form = find("#payment-form")
        form_intent = form["data-stripe-intent-secret-value"]

        assert_equal mock_stripe_intent, form_intent
      end
    end

    test "failing to create a payment method" do
      mock_stripe_result = Minitest::Mock.new
      mock_stripe_result.expect :success?, false
      mock_stripe_result.expect :error, "Something went wrong"

      mock_stripe_checkout = Minitest::Mock.new
      # this will be called twice
      mock_stripe_checkout.expect :sync_payment_methods, nil, [@member.user]
      mock_stripe_checkout.expect :sync_payment_methods, nil, [@member.user]
      mock_stripe_checkout.expect :prepare_to_collect_payment_info, mock_stripe_result, [@member.user]

      StripeCheckout.stub :build, mock_stripe_checkout do
        visit account_payment_methods_url
        click_link "Add new payment method"

        assert_text "There was a problem connecting to our payment processor."
        assert_equal account_payment_methods_path, current_path
      end
    end

    test "deleting a payment method" do
      payment_method_to_keep = create(:payment_method, :active, user: @member.user)
      payment_method_to_delete = create(:payment_method, :active, user: @member.user)

      mock_stripe_checkout = Minitest::Mock.new
      # this will be called twice
      mock_stripe_checkout.expect :sync_payment_methods, nil, [@member.user]
      mock_stripe_checkout.expect :sync_payment_methods, nil, [@member.user]
      mock_stripe_checkout.expect :delete_payment_method, Result.success(nil) do |given_payment_method|
        given_payment_method.detach!
      end

      StripeCheckout.stub :build, mock_stripe_checkout do
        visit account_payment_methods_url

        assert_text payment_method_to_keep.last_four
        assert_text payment_method_to_delete.last_four

        within("#payment-method-#{payment_method_to_delete.id}") do
          accept_confirm { click_button "Delete" }
        end

        assert_text "Successfully deleted payment method"
        assert_text payment_method_to_keep.last_four
        refute_text payment_method_to_delete.last_four
      end
    end
  end
end
