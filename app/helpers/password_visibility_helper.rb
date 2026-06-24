module PasswordVisibilityHelper
  def password_visibility_field(form, method, options = {})
    options = options.deep_merge(data: {password_visibility_target: "input"})

    tag.div(data: {controller: "password-visibility"}) do
      form.password_field(method, options) + password_visibility_button(form, method)
    end
  end

  private

  def password_visibility_button(form, method)
    tag.button "Show password", type: "button",
      data: {password_visibility_target: "button", action: "password-visibility#toggle"},
      aria: {pressed: "false", controls: form.field_id(method)}
  end
end
