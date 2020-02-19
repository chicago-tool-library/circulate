desc "Get a renewal request link for a member"
task :renewal_request_url, [:member_id] => :environment do |task, args|
  Time.use_zone("America/Chicago") do
    member = Member.find(args.fetch(:member_id))
    retriever = MemberRetriever.new(member_id: member.id)
    puts Rails.application.routes.url_helpers.renewal_request_url(id: retriever.encrypt, only_path: true)
  end
end