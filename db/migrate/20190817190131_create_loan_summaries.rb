# frozen_string_literal: true

class CreateLoanSummaries < ActiveRecord::Migration[6.0]
  def change
    create_view :loan_summaries
  end
end
