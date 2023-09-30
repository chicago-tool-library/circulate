# frozen_string_literal: true

json.array! @loans, partial: "admin/loans/loan", as: :loan
