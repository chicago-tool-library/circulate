module Account
  class HomeController < BaseController
    def index
      @loans = current_member.loans.includes(:item).order(:due_at)
      @holds = current_member.holds.includes(:item)
    end
  end
end