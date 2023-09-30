# frozen_string_literal: true

namespace :categories do
  desc "Updates the category_nodes materialized view"
  task refresh_nodes: :environment do
    CategoryNode.refresh
  end
end
