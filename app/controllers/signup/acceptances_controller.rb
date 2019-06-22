module Signup
  class AcceptancesController < BaseController
    before_action :load_member
    before_action :load_agreement

    def create
      @acceptance = @agreement.acceptances.new(member: @member, terms: agreement_params[:terms])
      if @acceptance.save
        redirect_to next_signup_step(@agreement)
      else
        render "signup/agreements/show"
      end
    end

    def destroy
    end

    private

    def agreement_params
      params.require(:agreement_acceptance).permit(:terms)
    end

    def load_member
      if session[:timeout] < Time.current - 15.minutes
        session.delete :timeout
        session.delete :member_id
        flash[:error] = "Your session expired. Please come into the library to complete signup."
        redirect_to new_signup_member_path
      end
      @member = Member.find(session[:member_id])
    end

    def load_agreement
      @agreement = Agreement.find(params[:agreement_id])
    end
  end
end
