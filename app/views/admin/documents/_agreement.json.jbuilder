# frozen_string_literal: true

json.extract! agreement, :code, :name, :summary, :body, :updated_at
json.url admin_agreement_url(agreement, format: :json)
