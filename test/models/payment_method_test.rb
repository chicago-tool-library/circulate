require "test_helper"

class PaymentMethodTest < ActiveSupport::TestCase
  test "detach from a user" do
    payment_method = create(:payment_method)
    assert_equal PaymentMethod.statuses[:active], payment_method.status

    payment_method.detach!
    assert_equal PaymentMethod.statuses[:detached], payment_method.status
    refute PaymentMethod.active.find_by(id: payment_method.id)
  end
end
