namespace :neon do
  task search: :environment do
    client = Neon::Client.new(ENV.fetch("NEON_ORGANIZATION_ID"), ENV.fetch("NEON_API_KEY"))
    account = client.search_account("jim@chicagotoollibrary.org")

    # Member.verified.limit(1).each do |member|
    #   account = client.search_account(member.email)
    #   local = Neon.account_to_member(account)
    #   # puts local.inspect
    #   # puts member.attributes.inspect
    #   pp Hashdiff.diff(member.attributes, local, strip: true)
    # end
  end
end
