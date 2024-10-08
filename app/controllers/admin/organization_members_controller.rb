class Admin::OrganizationMembersController < Admin::BaseController
  before_action :set_organization_member, only: %i[show edit update destroy]
  before_action :set_organization, only: %i[new create]

  def show
  end

  def new
    @organization_member = OrganizationMember.new
    @user = User.new
  end

  def create
    @organization_member = OrganizationMember.create_with_user(
      email: user_email,
      organization: @organization,
      **organization_member_params
    )
    @user = @organization_member.user

    if @organization_member.persisted?
      redirect_to admin_organization_member_path(@organization_member), success: "Organization Member was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @organization_member.update(organization_member_params)
      redirect_to admin_organization_member_path(@organization_member), success: "Organization Member was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @organization_member.destroy!
    redirect_to admin_organization_path(@organization_member.organization), success: "Organization Member was successfully destroyed."
  end

  private

  def set_organization_member
    @organization_member = OrganizationMember.find(params[:id])
  end

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def organization_member_params
    params.require(:organization_member).permit(:full_name, :role)
  end

  def user_email
    params.dig(:organization_member, :users_attributes, :email)
  end
end
