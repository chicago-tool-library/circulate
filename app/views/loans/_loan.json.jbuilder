json.extract! loan, :id, :item_id, :member_id, :due_at, :ended_at, :created_at, :updated_at
json.url loan_url(loan, format: :json)
