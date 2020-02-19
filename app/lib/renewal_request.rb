class RenewalRequest
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :loan_ids, default: []
  attribute :loan_source

  validates_size_of :loan_ids, minimum: 1, message: "Please select at least one item to renew"

  validate do
    load_loans
    @loans.each do |loan|
      unless loan.renewable?
        errors.add(:loan_ids, "loan #{loan.id} can't be renewed")
      end
    end
  end

  def loan_ids=(ids)
    write_attribute :loan_ids, ids.map(&:to_i)
  end

  def commit
    return false unless valid?
    @loans.each(&:renew!)
    true
  end

  private

  def load_loans
    @loans = loan_source.find(loan_ids)
  end
end