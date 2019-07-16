json.extract! agreement, :id, :name, :summary, :body, :position, :active, :created_at, :updated_at
json.url admin_agreement_url(agreement, format: :json)
