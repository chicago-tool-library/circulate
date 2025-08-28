require "test_helper"

class BorrowPolicyAuthorizerTest < ActiveSupport::TestCase
  class ResultInitializationTest < ActiveSupport::TestCase
    setup do
      @borrow_policy = create(:borrow_policy, :requires_approval)
      @member = create(:member)
      @subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member)
    end

    test "requires a borrow policy" do
      assert_equal @borrow_policy, @subject.borrow_policy
    end

    test "requires a member" do
      assert_equal @member, @subject.member
    end

    test "accepts a borrow policy approval" do
      assert_nil @subject.borrow_policy_approval

      borrow_policy_approval = create(:borrow_policy_approval, borrow_policy: @borrow_policy, member: @member)
      @subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      assert_equal borrow_policy_approval, @subject.borrow_policy_approval
    end
  end

  class ResultCanRequestAndReasonsWhyCannotRequestTest < ActiveSupport::TestCase
    setup do
      @before_cutoff = BorrowPolicyAuthorizer::NUMBER_OF_MONTHS.months.ago - 1.day
      @after_cutoff = BorrowPolicyAuthorizer::NUMBER_OF_MONTHS.months.ago + 1.day
      @borrow_policy = create(:borrow_policy, :requires_approval)
      @member = create(:member)
    end

    test "is false when the member is too new" do
      @member.update!(created_at: @after_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member)

      refute subject.can_request?
      assert_equal ["must be a member for more than #{BorrowPolicyAuthorizer::NUMBER_OF_MONTHS} months"], subject.reasons_why_cannot_request
    end

    test "is true when the member is old enough and they haven't requested approval before" do
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member)

      assert subject.can_request?
      assert_equal [], subject.reasons_why_cannot_request
    end

    test "is false when the member is old enough and approval is approved" do
      borrow_policy_approval = create(:borrow_policy_approval, :approved, member: @member, borrow_policy: @borrow_policy, updated_at: @before_cutoff)
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      refute subject.can_request?
      assert_equal ["member is already approved"], subject.reasons_why_cannot_request
    end

    test "is false when the member is old enough and approval is requested" do
      borrow_policy_approval = create(:borrow_policy_approval, :requested, member: @member, borrow_policy: @borrow_policy, updated_at: @before_cutoff)
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      refute subject.can_request?
      assert_equal ["member already has a pending request"], subject.reasons_why_cannot_request
    end

    test "is false when the member is old enough, approval is recently rejected" do
      borrow_policy_approval = create(:borrow_policy_approval, :rejected, member: @member, borrow_policy: @borrow_policy, updated_at: @after_cutoff)
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      refute subject.can_request?
      assert_equal ["request was rejected in the last #{BorrowPolicyAuthorizer::NUMBER_OF_MONTHS} months"], subject.reasons_why_cannot_request
    end

    test "is true when the member is old enough, approval is not recently rejected" do
      borrow_policy_approval = create(:borrow_policy_approval, :rejected, member: @member, borrow_policy: @borrow_policy, updated_at: @before_cutoff)
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      assert subject.can_request?
      assert_equal [], subject.reasons_why_cannot_request
    end

    test "is false when the member is old enough, approval is recently revoked" do
      borrow_policy_approval = create(:borrow_policy_approval, :revoked, member: @member, borrow_policy: @borrow_policy, updated_at: @after_cutoff)
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      refute subject.can_request?
      assert_equal ["approval was revoked in the last #{BorrowPolicyAuthorizer::NUMBER_OF_MONTHS} months"], subject.reasons_why_cannot_request
    end

    test "is true when the member is old enough, approval is not recently revoked" do
      borrow_policy_approval = create(:borrow_policy_approval, :revoked, member: @member, borrow_policy: @borrow_policy, updated_at: @before_cutoff)
      @member.update!(created_at: @before_cutoff)
      subject = BorrowPolicyAuthorizer::Result.new(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)

      assert subject.can_request?
      assert_equal [], subject.reasons_why_cannot_request
    end
  end

  class CheckTest < ActiveSupport::TestCase
    setup do
      @borrow_policy = create(:borrow_policy, :requires_approval)
      @member = create(:member)
      @subject = BorrowPolicyAuthorizer.check(borrow_policy: @borrow_policy, member: @member)
    end

    test "returns a result with the given borrow policy, member, and approval" do
      @subject = BorrowPolicyAuthorizer.check(borrow_policy: @borrow_policy, member: @member)
      assert_equal @borrow_policy, @subject.borrow_policy
      assert_equal @member, @subject.member
      assert_nil @subject.borrow_policy_approval

      borrow_policy_approval = create(:borrow_policy_approval, borrow_policy: @borrow_policy, member: @member)
      @subject = BorrowPolicyAuthorizer.check(borrow_policy: @borrow_policy, member: @member, borrow_policy_approval:)
      assert_equal @borrow_policy, @subject.borrow_policy
      assert_equal @member, @subject.member
      assert_equal borrow_policy_approval, @subject.borrow_policy_approval
    end

    test "returns a result that with a borrow policy if one can be found and none was given" do
      borrow_policy_approval = create(:borrow_policy_approval, borrow_policy: @borrow_policy, member: @member)
      @subject = BorrowPolicyAuthorizer.check(borrow_policy: @borrow_policy, member: @member)

      assert_equal borrow_policy_approval, @subject.borrow_policy_approval
    end
  end
end
