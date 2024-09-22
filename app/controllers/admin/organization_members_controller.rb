class Admin::OrganizationMembersController < Admin::BaseController
  before_action :set_organization_member, only: %i[show]

  def show
  end

  private

  def set_organization_member
    @organization_member = OrganizationMember.find(params[:id])
  end
end
