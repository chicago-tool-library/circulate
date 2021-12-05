module Account
  class HomeController < BaseController
    def index
      @library_updates = LibraryUpdate.published.newest_first
      @loans = current_member.loans.checked_out
      @ready_holds_count = current_member.holds.active.started.count
      @waiting_holds_count = current_member.holds.active.waiting.count
    end
  end
end
