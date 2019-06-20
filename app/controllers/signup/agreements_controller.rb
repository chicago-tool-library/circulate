module Signup
  class AgreementsController < BaseController
    def show
      @agreement = Agreement.find(params[:id])
      @acceptance = @agreement.acceptances.new
      activate_agreement_step(@agreement)
    end
  end
end