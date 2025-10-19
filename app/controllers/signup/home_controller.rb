module Signup
  class HomeController < BaseController
    before_action :is_membership_enabled?

    def index
      @hide_steps = true
      @org_signup_url = if FeatureFlags.group_lending_enabled?
        signup_organizations_policies_url
      else
        ENV.fetch("ORGANIZATION_SIGNUP_URL")
      end
    end
  end
end
