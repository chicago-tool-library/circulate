class Admin::OrganizationsController < Admin::BaseController
  before_action :set_organization, only: %i[show edit update destroy]

  # GET /admin/organizations or /admin/organizations.json
  def index
    @organizations = Organization.all
  end

  # GET /admin/organizations/1 or /admin/organizations/1.json
  def show
  end

  # GET /admin/organizations/new
  def new
    @organization = Organization.new
  end

  # GET /admin/organizations/1/edit
  def edit
  end

  # POST /admin/organizations or /admin/organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to admin_organization_url(@organization), success: "Organization was successfully created." }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /admin/organizations/1 or /admin/organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to admin_organization_url(@organization), success: "Organization was successfully updated." }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /admin/organizations/1 or /admin/organizations/1.json
  def destroy
    @organization.destroy!

    respond_to do |format|
      format.html { redirect_to admin_organizations_url, success: "Organization was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def organization_params
    params.require(:organization).permit(:name, :website)
  end
end
