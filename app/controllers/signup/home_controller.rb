module Signup
  class HomeController < BaseController
    before_action :is_membership_enabled?

    def index
      @hide_steps = true
      @org_signup_url = FeatureFlags.group_lending_enabled? ? signup_organization_url : "https://www.chicagotoollibrary.org/org-membership-cost"
    end
  end
end
