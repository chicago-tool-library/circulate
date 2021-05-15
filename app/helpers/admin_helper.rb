module AdminHelper
  def index_header(title, icon: nil, &block)
    render "shared/index_header", title: title, icon: icon, &block
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

  def item_attachment_kind_options
    ItemAttachment.kinds.map { |k, v| [k.titleize, v] }
  end

  def tab_link(label, path, badge: nil)
    opts = badge.present? && badge != 0 ? {class: "badge", data: {badge: badge}} : {}
    tag.li(class: "tab-item #{"active" if current_page?(path)}") do
      link_to label, path, **opts
    end
  end

  def renewal_tooltop(renewable, renewal_limit, &block)
    if renewable
      tag.span(&block)
    else
      message = if renewal_limit == 0
        "Item can not be renewed."
      else
        "Renewed the maximum number of times (#{renewal_limit})."
      end
      tag.span(
        class: "tooltip tooltip-bottom",
        data: {tooltip: message},
        &block
      )
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

  def audit_description(audit, key, values)
    value = audit.action == "create" ? values : values.last

    case key
    when "status"
      value = Item.statuses.invert[value]
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

  def modal(title:, body:, &block)
    render "shared/modal", title: title, body: body, &block
  end

  def sort_by_member_and_time(appointments)
    appointments
      .group_by { |a| a.member }
      .map { |member, appointments| [appointments.map(&:starts_at).min, appointments] }
      .sort_by { |first_time, appointments| first_time }
      .flat_map { |_, appointments| appointments }
  end
end
