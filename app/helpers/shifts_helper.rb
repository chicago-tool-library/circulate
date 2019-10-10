module ShiftsHelper
  def signed_in_via_google?
    session[:email].present?
  end
end