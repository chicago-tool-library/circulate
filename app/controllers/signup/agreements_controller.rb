module Signup
  class AgreementsController < BaseController
    before_action :load_member

    def show
      @agreement = Agreement.find(params[:id])
      @acceptance = @agreement.acceptances.new
      activate_agreement_step(@agreement)
    end
  end
end
