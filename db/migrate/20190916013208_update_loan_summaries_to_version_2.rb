# frozen_string_literal: true

class UpdateLoanSummariesToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :loan_summaries, version: 2, revert_to_version: 1
  end
end
