require "test_helper"

class SquarePaymentJobTest < ActiveJob::TestCase
  test "handles a successful payment" do
    @member = create(:member)

    mock_fetched_order = Minitest::Mock.new
    mock_fetched_order.expect :amount, Money.new(1234)
    mock_fetched_order.expect :amount, Money.new(1234)
    mock_fetched_order.expect :created_by_circulate?, true
    mock_fetched_order.expect :member_id, @member.id.to_s
    mock_fetched_order.expect :id, "abcd1234"

    mock_result = Minitest::Mock.new
    mock_result.expect :failure?, false
    mock_result.expect :value, mock_fetched_order

    mock_checkout = Minitest::Mock.new
    mock_checkout.expect(:fetch_order, mock_result, order_id: "abcd1234")
    mock_checkout.expect(:complete_order, Result.success("updated order"), [mock_fetched_order])

    SquareCheckout::Client.stub :new, mock_checkout do
      assert_difference "@member.memberships.count" => 1, "@member.adjustments.count" => 2 do
        perform_enqueued_jobs do
          SquarePaymentJob.perform_later(order_id: "abcd1234")
        end
      end
    end

    assert_mock mock_fetched_order
    assert_mock mock_result
    assert_mock mock_checkout
  end

  test "handles a payment not from Circulate" do
    mock_fetched_order = Minitest::Mock.new
    mock_fetched_order.expect :created_by_circulate?, false

    mock_result = Minitest::Mock.new
    mock_result.expect :failure?, false
    mock_result.expect :value, mock_fetched_order

    mock_checkout = Minitest::Mock.new
    mock_checkout.expect(:fetch_order, mock_result, order_id: "abcd1234")

    SquareCheckout::Client.stub :new, mock_checkout do
      assert_no_difference "Membership.count", "Adjustment.count" do
        perform_enqueued_jobs do
          SquarePaymentJob.perform_later(order_id: "abcd1234")
        end
      end
    end

    assert_mock mock_fetched_order
    assert_mock mock_result
    assert_mock mock_checkout
  end

  test "handles having already run" do
    create(:square_payment_adjustment, square_transaction_id: "abcd1234")

    mock_checkout = Minitest::Mock.new

    SquareCheckout::Client.stub :new, mock_checkout do
      assert_no_difference "Membership.count", "Adjustment.count" do
        perform_enqueued_jobs do
          SquarePaymentJob.perform_later(order_id: "abcd1234")
        end
      end
    end

    assert_mock mock_checkout
  end
end
