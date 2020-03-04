module AdminHelper
  def index_header(title, &block)
    render "shared/index_header", title: title, &block
  end

  def flash_message(key)
    if flash.key?(key)
      tag.div(class: "toast toast-#{key}", data: {controller: "alert"}) do
        tag.button(class: "btn btn-clear float-right", data: {action: "alert#remove"}) + flash[key]
      end
    end
  end

  def empty_state(title, subtitle: nil, icon: nil, &block)
    render "shared/empty_state", title: title, subtitle: subtitle, icon: icon, &block
  end

  def preferred_or_default_name(member)
    return member.preferred_name if member.preferred_name.present?

    member.full_name.split.first
  end

  def membership_payment_source_options
    Adjustment.payment_sources.slice("cash", "square")
  end

  def tab_link(label, path)
    tag.li(class: "tab-item #{"active" if current_page?(path)}") do
      link_to label, path
    end
  end

  def action_bar(message, icon: "", type: nil, &block)
    icon = feather_icon(icon) unless icon.empty?
    klass = "action-bar-#{type} " unless type.nil?
    tag.div(class: "action-bar #{klass}clearfix") do
      tag.div(icon + message, class: "float-left") +
        tag.div(class: "float-right", &block)
    end
  end
end
