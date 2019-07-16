class UpdateAgreementAcceptances < ActiveRecord::Migration[6.0]
  def change
    remove_column :agreement_acceptances, :agreement_id
  end
end
