module MemberOrdering
  def index_order
    options = {
      "full_name" => "lower(members.full_name) ASC",
      "added" => "members.created_at DESC",
    }
    options.fetch(params[:sort]) { options["added"] }
  end
end