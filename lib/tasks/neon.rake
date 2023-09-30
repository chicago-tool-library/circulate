# frozen_string_literal: true

namespace :neon do
  task search: :environment do
    client = Neon::Client.new(ENV.fetch("NEON_ORGANIZATION_ID"), ENV.fetch("NEON_API_KEY"))

    Member.verified.each do |member|
      account = client.search_account(member.email)
      payload = Neon.member_to_account(member)
      client.update_account(account["individualAccount"]["accountId"], account.deep_merge(payload))
      sleep 1
    end
  end
end
