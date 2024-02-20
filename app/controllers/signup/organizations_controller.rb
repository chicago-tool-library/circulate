module Signup
  class OrganizationsController < ApplicationController
    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)

      respond_to do |format|
        if @organization.save
          format.html { redirect_to root_url, notice: "Organization was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name)
    end
  end
end
