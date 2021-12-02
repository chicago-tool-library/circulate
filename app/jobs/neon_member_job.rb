class NeonMemberJob < ApplicationJob
  include SuckerPunch::Job

  def perform(member_id)
    member = Member.find(member_id)
    organization_id, api_key = Neon.credentials_for_library(member.library)
    client = Neon::Client.new(organization_id, api_key)
    client.update_account_with_member(member)
  end
end
