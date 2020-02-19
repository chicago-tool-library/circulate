desc "Get an account summary link for a member"
task :account_summary_url, [:member_id] => :environment do |task, args|
  Time.use_zone("America/Chicago") do
    member = Member.find(args.fetch(:member_id))
    retriever = MemberRetriever.new(member_id: member.id)
    puts Rails.application.routes.url_helpers.account_summary_url(account_id: retriever.encrypt, only_path: true)
  end
end