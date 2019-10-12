module AdjustmentsHelper
  def adjustment_payment_source_options
    Adjustment.payment_sources
  end
end
