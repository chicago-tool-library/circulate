module Signup
  class HomeController < BaseController
    before_action :is_membership_enabled?

    def index
      @hide_steps = true
      @org_signup_url = if FeatureFlags.group_lending_enabled?
        signup_organizations_policies_url
      else
        "https://docs.google.com/forms/d/e/1FAIpQLScr5icM-G09-MwxkluIYibcWbzNm8t0xYRODgFoXtt_Hom1dQ/viewfor"
      end
    end
  end
end
