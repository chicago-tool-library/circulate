module Admin
  class MembersController < BaseController
    before_action :set_member, only: [:show, :edit, :update, :destroy]

    # GET /members
    # GET /members.json
    def index
      member_scope = params[:filter] == "closed" ? Member.closed : Member.all
      @members = member_scope.order(index_order)
    end

    # GET /members/1
    # GET /members/1.json
    def show
      @new_item_numbers = []
      @new_loans = {}
      @active_loans = @member.active_loans.by_creation_date
      @recent_loans = @member.loans.recently_returned.includes(:adjustment).by_end_date.limit(10)
    end

    # GET /members/new
    def new
      @member = Member.new
    end

    # GET /members/1/edit
    def edit
    end

    # POST /members
    # POST /members.json
    def create
      @member = Member.new(member_params)

      respond_to do |format|
        if @member.save
          format.html { redirect_to [:admin, @member], notice: "Member was successfully created." }
          format.json { render :show, status: :created, location: @member }
        else
          format.html { render :new }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /members/1
    # PATCH/PUT /members/1.json
    def update
      respond_to do |format|
        if @member.update(member_params)
          format.html { redirect_to [:admin, @member], notice: "Member was successfully updated." }
          format.json { render :show, status: :ok, location: @member }
        else
          format.html { render :edit }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /members/1
    # DELETE /members/1.json
    def destroy
      @member.destroy
      respond_to do |format|
        format.html { redirect_to admin_members_url, notice: "Member was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(
        :full_name, :preferred_name, :email, :pronoun, :custom_pronoun, :phone_number, :postal_code,
        :desires, :reminders_via_email, :reminders_via_text, :receive_newsletter, :volunteer_interest,
        :notes, :status,
      )
    end
    
    def index_order
      options = {
        "full_name" => "lower(members.full_name) ASC",
        "added" => "members.created_at DESC",
      }
      options.fetch(params[:sort]) { options["added"] }
    end
  end
end
