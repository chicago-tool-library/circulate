module LoansHelper
  def undo_button(loan)
    name, method, path, params = if loan.ended?
      ["return", :patch, admin_loan_path(loan), {loan: {ended_at: nil}}]
    elsif loan.renewal?
      ["renewal", :delete, admin_renewal_path(loan)]
    else
      ["loan", :delete, admin_loan_path(loan)]
    end
    button_to path, method: method, class: "btn btn-sm", remote: true, params: params do
      feather_icon("x") + "Undo #{name}"
    end
  end

  def humanize_due_date(loan)
    if loan.due_at.to_date == Date.today
      "today"
    elsif loan.due_at.to_date == Date.tomorrow
      "tomorrow"
    else
      loan.due_at.strftime("%a %m/%d")
    end
  end
end
