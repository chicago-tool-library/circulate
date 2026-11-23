class AddGoogleDocUrlToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :google_doc_url, :string
  end
end
