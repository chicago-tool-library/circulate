# frozen_string_literal: true

class AddDefaultDocuments < ActiveRecord::Migration[6.0]
  class MigrationDocument < ActiveRecord::Base
    self.table_name = :documents
  end

  def change
    MigrationDocument.delete_all
    MigrationDocument.create!(code: "agreement", name: "Agreement")
    MigrationDocument.create!(code: "borrow_policy", name: "Borrow Policy")
    MigrationDocument.create!(code: "code_of_conduct", name: "Code of Conduct")
  end
end
