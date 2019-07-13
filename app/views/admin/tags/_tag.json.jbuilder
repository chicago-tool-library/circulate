json.extract! category, :id, :name, :slug, :created_at, :updated_at
json.url admin_category_url(category, format: :json)
