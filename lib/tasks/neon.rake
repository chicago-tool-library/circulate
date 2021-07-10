namespace :neon do
  task search: :environment do
    client = Neon::Client.new(ENV.fetch("NEON_ORGANIZATION_ID"), ENV.fetch("NEON_API_KEY"))

    client.search_account("jim@chicagotoollibrary.org")
  end
end
