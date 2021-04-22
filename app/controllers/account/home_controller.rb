module Account
  class HomeController < BaseController
    def index
      @loans = current_member.loans.checked_out.includes(:item, :renewal_requests).order(:due_at)
      @holds = current_member.active_holds.includes(:item)
    end
  end
end
