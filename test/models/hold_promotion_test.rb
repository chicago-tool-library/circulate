require "test_helper"

# An item that frees up goes to the next member in line right away instead of
# waiting for the scheduled holds task.
class HoldPromotionTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @item = create(:item)
  end

  test "returning a loan promotes the item's line" do
    loan = create(:loan, item: @item)
    assert_enqueued_with(job: StartWaitingHoldsJob, args: [@item.id]) do
      loan.update!(ended_at: Time.current)
    end
  end

  test "ending a ready hold promotes the item's line" do
    hold = create(:started_hold, item: @item)
    assert_enqueued_with(job: StartWaitingHoldsJob, args: [@item.id]) do
      hold.update!(ended_at: Time.current)
    end
  end

  test "cancelling a ready hold promotes the item's line" do
    hold = create(:started_hold, item: @item)
    assert_enqueued_with(job: StartWaitingHoldsJob, args: [@item.id]) do
      hold.destroy!
    end
  end

  test "a hold turning into a loan doesn't promote anything" do
    hold = create(:started_hold, item: @item)
    loan = create(:loan, item: @item, member: hold.member)
    assert_no_enqueued_jobs(only: StartWaitingHoldsJob) do
      hold.update!(ended_at: Time.current, loan:)
    end
  end

  test "the job starts the next hold and tells the member" do
    hold = create(:hold, item: @item)
    assert_emails 1 do
      StartWaitingHoldsJob.perform_now(@item.id)
    end
    assert hold.reload.started?
  end

  test "the job leaves other items' lines alone" do
    other = create(:hold)
    create(:hold, item: @item)
    StartWaitingHoldsJob.perform_now(@item.id)
    refute other.reload.started?
  end
end
