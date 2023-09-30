# frozen_string_literal: true

class UpdateLoanSummariesToVersion3 < ActiveRecord::Migration[6.0]
  def change
    update_view :loan_summaries, version: 3, revert_to_version: 2
  end
end
