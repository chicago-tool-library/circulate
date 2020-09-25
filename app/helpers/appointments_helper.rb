module AppointmentsHelper
  def pickup_or_dropoff(loan)
    loan.blank? ? "pick-up" : "drop-off"
  end
end
