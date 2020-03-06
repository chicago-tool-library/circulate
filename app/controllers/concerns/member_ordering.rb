module MemberOrdering
  def index_order
    options = {
      "name" => "lower(coalesce(nullif(members.preferred_name, ''), members.full_name)) ASC",
      "added" => "members.created_at DESC"
    }
    Arel.sql options.fetch(params[:sort]) { options["added"] }
  end
end
