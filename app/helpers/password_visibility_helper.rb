module PasswordVisibilityHelper
  def password_visibility_field(form, method, options = {})
    options = options.deep_merge(data: {password_visibility_target: "input"})

    tag.div(class: "password-visibility", data: {controller: "password-visibility"}) do
      form.password_field(method, options) + password_visibility_button(form, method)
    end
  end

  private

  def password_visibility_button(form, method)
    tag.button type: "button", class: "password-visibility-toggle",
      data: {password_visibility_target: "button", action: "password-visibility#toggle"},
      aria: {pressed: "false", controls: form.field_id(method)} do
      tag.span(data: {password_visibility_target: "shownLabel"}) { feather_icon("eye") + tag.span("Show password", class: "visually-hidden") } +
        tag.span(class: "d-none", data: {password_visibility_target: "hiddenLabel"}) { feather_icon("eye-off") + tag.span("Hide password", class: "visually-hidden") }
    end
  end
end
