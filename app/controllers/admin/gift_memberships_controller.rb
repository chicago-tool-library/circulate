module Admin
  class GiftMembershipsController < BaseController
    include Pagy::Backend

    before_action :set_gift_membership, only: [:show, :edit, :update, :destroy]

    def index
      @pagy, @gift_memberships = pagy(GiftMembership.order(created_at: :desc))
    end

    def new
      @gift_membership = GiftMembership.new
    end

    def edit
    end

    def show
    end

    def create
      @gift_membership = GiftMembership.new(gift_membership_params)

      respond_to do |format|
        if @gift_membership.save
          GiftPurchaserMailer.with(gift_membership: @gift_membership).confirmation.deliver_later

          format.html { redirect_to admin_gift_memberships_url, success: "Gift membership was successfully created.", status: :see_other }
          format.json { render :show, status: :created, location: [:admin, @gift_membership] }
        else
          format.html { render :new, status: :unprocessable_content }
          format.json { render json: @gift_membership.errors, status: :unprocessable_content }
        end
      end
    end

    def update
      respond_to do |format|
        if @gift_membership.update(gift_membership_params)
          format.html { redirect_to admin_gift_memberships_url, success: "Gift membership was successfully updated.", status: :see_other }
          format.json { render :show, status: :ok, location: [:admin, @gift_membership] }
        else
          format.html { render :edit, status: :unprocessable_content }
          format.json { render json: @gift_membership.errors, status: :unprocessable_content }
        end
      end
    end

    def destroy
      @gift_membership.destroy
      respond_to do |format|
        format.html { redirect_to admin_gift_memberships_url, success: "Gift membership was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      end
    end

    private

    def set_gift_membership
      @gift_membership = GiftMembership.find(params[:id])
    end

    def gift_membership_params
      params.require(:gift_membership).permit(:purchaser_email, :purchaser_name, :amount, :recipient_name)
    end
  end
end
