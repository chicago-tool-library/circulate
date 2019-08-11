require "test_helper"

class AdjustmentTest < ActiveSupport::TestCase
  test "factory definitions" do
    create(:fine_adjustment)
    create(:membership_adjustment)
    create(:cash_payment_adjustment)
    create(:square_payment_adjustment)
  end

  # test "requires a square_transaction_id when source is square" do
  #   adjustment = build(:adjustment, payment_source: "square")

  #   refute adjustment.valid?

  #   assert_equal ["can't be blank"], adjustment.errors[:square_transaction_id]
  # end
end
