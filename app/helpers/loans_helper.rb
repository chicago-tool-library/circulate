module LoansHelper
  def undo_button(loan)
    name, path = if loan.renewal?
      ["renewal", admin_renewal_path(loan)]
    else
      ["loan", admin_loan_path(loan)]
    end
    button_to path, method: :delete, class: "btn btn-sm" do
      feather_icon("x") + "Undo #{name}"
    end
  end
end
