class MemberProfilesController < ApplicationController
    def show
      @member = Member.first
    end
end
