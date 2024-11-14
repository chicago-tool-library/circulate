module ItemsHelper
  include Pagy::Frontend

  attr_reader :filter_params

  def item_categories(item)
    item.categories.select(:id, :name)
      .order(:name)
      .map { |obj| link_to(obj.name, items_path(category: obj.id)) }
      .join(", ")
  end

  def item_status_name(status)
    Item::STATUS_NAMES[status]
  end

  def item_status_options(disabled_statuses: [])
    Item.statuses.map do |key, value|
      description = " (#{Item::STATUS_DESCRIPTIONS[key]})" if Item::STATUS_DESCRIPTIONS[key]
      ["#{Item::STATUS_NAMES[key]}#{description}", key].tap do |option|
        option << {disabled: true} if disabled_statuses.include?(key)
      end
    end
  end

  def item_power_source_options
    Item.power_sources.map do |key, value|
      [value.titleize, key]
    end
  end

  def item_powered_by_label(item)
    Item.power_sources[item.power_source]&.titleize
  end

  def borrow_policy_options
    BorrowPolicy.alpha_by_code.map do |borrow_policy|
      ["(#{borrow_policy.code}) #{borrow_policy.name}: #{borrow_policy.description}", borrow_policy.id]
    end
  end

  def category_nav(categories, current_category = nil)
    return unless categories

    tag.ul class: "nav tag-nav" do
      categories.map { |category|
        is_parent = category.parent_id.nil?
        tag.li(class: "nav-item #{"active" if category.id == current_category&.id} #{"parent" if is_parent}") {
          is_parent ? link_to(category.name, category: category.id) : "&nbsp;&nbsp;".html_safe * category.path_ids.size + "-".html_safe + link_to(category.name, category: category.id)
        }
      }.join.html_safe
    end
  end

  def status_hint(item)
    status_maintenance_hint = item.persisted? ? link_to("create a ticket", new_admin_item_ticket_path(item)) : "create a ticket"
    "Only active items can be checked out. To mark an item as in maintenance, please #{status_maintenance_hint}.".html_safe
  end

  class TreeNode
    attr_accessor :children
    attr_accessor :value

    def initialize(value)
      self.value = value
      self.children = {}
    end

    def [](key)
      children[key]
    end

    def []=(key, value)
      children[key] = value
    end
  end

  def category_tree_nav(categories, current_category = nil, count_method = :visible_items_count)
    root = TreeNode.new(nil)
    categories.sort_by { |c| c.path_ids.size }.each do |category|
      parent = category.path_ids[0..-2].reduce(root) { |node, id| node[id] }
      parent[category.id] = TreeNode.new(category)
    end

    tag.nav(class: "tree-nav", data: {controller: "tree-nav"}) do
      concat(tag.ul do
        root.children.values.sort_by { |node| node.value.name.downcase }.map do |node|
          concat(render_tree_node(node, current_category, count_method))
        end
      end)
    end
  end

  def render_tree_node(node, current_value, count_method)
    has_children = node.children.size > 0
    tag.li(class: "tree-node", data: {id: node.value.id}) do
      if has_children
        concat(
          tag.button(
            '<i class="icon icon-arrow-right">Toggle subcategories</i>'.html_safe,
            class: "tree-node-toggle",
            data: {action: "tree-nav#toggle"},
            "aria-expanded": false
          )
        )
      end

      # NOTE: This does not reflect current query / category selection
      count = node.value.send(count_method)

      concat(link_to((node.value.name + "&nbsp;(#{count})").html_safe, add_filter_param(:category, node.value.id)))
      if has_children
        concat(tag.ul(class: "tree-node-children") do
          node.children.values.sort_by { |node| node.value.name }.map do |child|
            concat(render_tree_node(child, current_value, count_method))
          end
        end)
      end
    end
  end

  def rotated_variant(image, options = {})
    if image.metadata.key? "rotation"
      options[:rotate] ||= image.metadata["rotation"].to_i
    end
    image.variant(options) if image.variable?
  end

  def item_image_url(image, options = {})
    if ENV["IMAGEKIT_URL"].present?
      transforms = if options[:resize_to_limit]
        width, height = options[:resize_to_limit]
        ["tr=w-#{width}", "h-#{height}", "c-at_max"]
      else
        []
      end

      if image.metadata.key? "rotation"
        transforms << "rt-#{image.metadata["rotation"]}"
      end

      parts = [
        ENV["IMAGEKIT_URL"],
        image.blob.key
      ]
      unless transforms.empty?
        parts << "?"
        parts << transforms.join(",")
      end

      parts.join
    else
      # fallback when there isn't an image proxy in place
      url_for(rotated_variant(image, options))
    end
  end

  def full_item_number(item)
    item.complete_number
  end

  def css_class_and_status_label(item)
    if item.active?
      if item.checked_out_exclusive_loan
        if item.overdue?
          ["label-error", "Overdue"]
        else
          ["label-warning", "Checked Out"]
        end
      elsif item.borrow_policy.uniquely_numbered? && item.active_holds.size > 0
        ["label-warning", "On Hold"]
      else
        ["label-success", "Available"]
      end
    elsif item.maintenance?
      ["", "In Maintenance"]
    else
      ["", "Unavailable"]
    end
  end

  def item_status_label(item)
    class_name, label = css_class_and_status_label(item)
    tag.span label, class: "label item-checkout-status #{class_name}"
  end

  def item_holds_label(item)
    if item.active?
      count = item.active_holds.size
      if count > 0
        tag.span pluralize(count, "hold"), class: "label item-hold-status"
      end
    end
  end

  def audit_item_status(audit)
    status_change = audit.audited_changes["status"]
    case status_change
    when Array
      item_status_name(status_change[1])
    when String
      item_status_name(status_change)
    end
  end

  def loan_description(loan)
    link = link_to preferred_or_default_name(loan.member), [:admin, loan.member]
    "Currently on loan to ".html_safe + link + "."
  end

  def item_location_span(item)
    location = []
    location << "area #{item.location_area}" unless item.location_area.blank?
    location << "shelf #{item.location_shelf}" unless item.location_shelf.blank?

    location.join(", ")
  end

  def add_filter_param(param, value)
    (filter_params || {}).merge(param => value).sort.to_h
  end
end
