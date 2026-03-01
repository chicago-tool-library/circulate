require "test_helper"

class PaymentMethodTest < ActiveSupport::TestCase
  [
    :payment_method,
    [:payment_method, :active],
    [:payment_method, :expired],
    [:payment_method, :detached]
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      payment_method = build(*factory_name)
      payment_method.valid?
      assert_equal({}, payment_method.errors.messages)
    end
  end

  test "detach from a user" do
    payment_method = create(:payment_method)
    assert_equal PaymentMethod.statuses[:active], payment_method.status

    payment_method.detach!
    assert_equal PaymentMethod.statuses[:detached], payment_method.status
    refute PaymentMethod.active.find_by(id: payment_method.id)
  end
end
