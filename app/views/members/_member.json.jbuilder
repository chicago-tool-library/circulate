json.extract! member, :id, :full_name, :preferred_name, :email, :pronoun, :custom_pronoun, :phone_number, :notes, :id_kind, :custom_id, :id_number, :address_erified, :created_at, :updated_at
json.url member_url(member, format: :json)
