require "test_helper"

module Admin
  class MembershipsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = create(:admin_user)
      sign_in @admin
      @member = create(:verified_member)
    end

    test "renders new form" do
      get admin_member_memberships_url(@member)
      assert_response :success
    end

    %w[square cash].each do |payment_source|
      test "creates new membership using #{payment_source}" do
        assert_difference "Adjustment.count", 2 do
          post admin_member_memberships_url(@member), params: {
            membership_form: {
              amount_dollars: 12,
              payment_source: payment_source,
              with_payment: "true",
              start_membership: "1"
            }
          }
        end
        assert_response :redirect

        membership = @member.memberships.last
        membership_adjustment, payment_adjustment = @member.adjustments.to_a[-2, 2]

        refute membership.pending?

        assert_equal membership, membership_adjustment.adjustable
        assert_equal Money.new(-1200), membership_adjustment.amount
        assert_equal "membership", membership_adjustment.kind
        assert_nil membership_adjustment.payment_source
        assert_nil membership_adjustment.square_transaction_id

        assert_nil payment_adjustment.adjustable
        assert_equal Money.new(1200), payment_adjustment.amount
        assert_equal "payment", payment_adjustment.kind
        assert_equal payment_source, payment_adjustment.payment_source
        assert_nil payment_adjustment.square_transaction_id
      end
    end

    %w[square cash].each do |payment_source|
      test "creates new pending membership using #{payment_source}" do
        assert_difference "Adjustment.count", 2 do
          post admin_member_memberships_url(@member), params: {
            membership_form: {
              amount_dollars: 12,
              payment_source: payment_source,
              with_payment: "true",
              start_membership: "0"
            }
          }
        end
        assert_response :redirect

        membership = @member.memberships.last
        assert membership.pending?
      end
    end

    test "creates new membership without payment" do
      post admin_member_memberships_url(@member), params: {
        membership_form: {
          with_payment: "false",
          start_membership: "1"
        }
      }
      assert_response :redirect

      membership = @member.memberships.last
      refute membership.pending?
    end

    test "creates new pending membership without payment" do
      post admin_member_memberships_url(@member), params: {
        membership_form: {
          with_payment: "false",
          start_membership: "0"
        }
      }
      assert_response :redirect

      membership = @member.memberships.last
      assert membership.pending?
    end
  end
end
