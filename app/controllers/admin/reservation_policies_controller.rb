module Admin
  class ReservationPoliciesController < BaseController
    before_action :load_reservation_policy, only: [:show, :edit, :update, :destroy]

    def index
      @reservation_policies = ReservationPolicy.all.order(:name)
    end

    def show
    end

    def new
      @reservation_policy = ReservationPolicy.new
    end

    def create
      @reservation_policy = ReservationPolicy.new(reservation_policy_params)

      if @reservation_policy.save
        redirect_to admin_reservation_policy_path(@reservation_policy),
          success: "Reservation policy was successfully created.",
          status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @reservation_policy.update(reservation_policy_params)
        redirect_to admin_reservation_policy_path(@reservation_policy),
          success: "Reservation policy was successfully updated.",
          status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation_policy.destroy!
      redirect_to admin_reservation_policies_path,
        success: "Reservation policy was successfully destroyed.",
        status: :see_other
    end

    private

    def reservation_policy_params
      params.require(:reservation_policy).permit(
        :default,
        :description,
        :maximum_duration,
        :maximum_start_distance,
        :minimum_start_distance,
        :name
      )
    end

    def load_reservation_policy
      @reservation_policy = ReservationPolicy.find(params[:id])
    end
  end
end
