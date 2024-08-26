module AdminHelper
  def index_header(title, icon: nil, &block)
    render "shared/index_header", title: title, icon: icon, &block
  end

  def breadcrumbs(*args)
    tag.ul(class: "breadcrumb") do
      args.each_slice(2) do |title, link|
        concat(
          tag.li(class: "breadcrumb-item") do
            link_to title, link
          end
        )
      end
    end
  end

  def flash_message(key, classname = key)
    if flash.key?(key)
      tag.div(class: "toast toast-#{classname}", data: {controller: "alert"}) do
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

  def link_to_member(member)
    link_to preferred_or_default_name(member), admin_member_path(member)
  end

  def membership_payment_source_options
    Adjustment.payment_sources.slice("cash", "square")
  end

  def item_attachment_kind_options
    ItemAttachment.kinds.map { |k, v| [k.titleize, v] }
  end

  def tab_link(label, path, badge: nil)
    opts = (badge.present? && badge != 0) ? {class: "badge", data: {badge: badge}} : {}
    tag.li(class: "tab-item #{"active" if current_page?(path)}") do
      link_to label, path, **opts
    end
  end

  def renewal_tooltop(renewable, renewal_limit, &)
    if renewable
      tag.span(&)
    else
      message = if renewal_limit == 0
        "Item can not be renewed."
      else
        "Renewed the maximum number of times (#{renewal_limit})."
      end
      tag.span(
        class: "tooltip tooltip-bottom",
        data: {tooltip: message},
        &
      )
    end
  end

  def action_bar(message, icon: "", type: nil, &)
    icon = feather_icon(icon) unless icon.empty?
    klass = "action-bar-#{type} " unless type.nil?
    tag.div(class: "action-bar #{klass}clearfix") do
      tag.div(icon + message, class: "float-left") +
        tag.div(class: "float-right", &)
    end
  end

  def audit_description(audit, key, values)
    value = (audit.action == "create") ? values : values.last

    case key
    when "status"
      # handle old integer item statuses from before the migration to an postgres enum
      value = if Integer === value
        ["pending", "active", "maintenance", "retired"][value]
      else
        Item.statuses.invert[value]
      end
      value = item_status_name(value)
    when "borrow_policy_id"
      value = BorrowPolicy.find(value).complete_name
    when "category_ids"
      key = "categories"
      category_names = Category.where(id: value).map(&:name)
      deleted_category_count = value.count - category_names.count
      if deleted_category_count > 0
        category_names << ["deleted category"] * deleted_category_count
      end
      value = category_names.join(", ")
    end

    if audit.action == "create" && value.blank?
      return
    end

    action = value.blank? ? " cleared " : " set to "
    tag.em(key.titleize) +
      action +
      tag.strong(value)
  end

  def modal(title:, body:, &)
    render "shared/modal", title: title, body: body, &
  end

  def appointment_in_schedule_path(appointment)
    admin_appointments_path(day: appointment.starts_at.to_date.to_s, anchor: dom_id(appointment))
  end
end
