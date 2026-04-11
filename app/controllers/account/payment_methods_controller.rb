module Account
  class PaymentMethodsController < BaseController
    def new
      @result = checkout.prepare_to_collect_payment_info(current_user)
      unless @result.success?
        Rails.logger.error(@result.error)
        flash[:error] = "There was a problem connecting to our payment processor."
        redirect_to account_payment_methods_path
      end
    end

    def index
      checkout.sync_payment_methods(current_user)
      @payment_methods = current_user.payment_methods.active
    end

    def destroy
      @payment_method = current_user.payment_methods.find(params[:id])
      result = checkout.delete_payment_method(@payment_method)
      if result.success?
        flash[:success] = "Successfully deleted payment method"
      else
        flash[:error] = result.error
      end
      redirect_to account_payment_methods_path, status: :see_other
    end

    private

    def checkout
      StripeCheckout.build
    end
  end
end
