json.extract! item, :id, :name, :description, :size, :brand, :model, :serial, :created_at, :updated_at
json.url item_url(item, format: :json)
