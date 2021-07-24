module ItemsHelper
  include Pagy::Frontend

  def item_categories(item)
    item.categories.select(:id, :name)
      .order(:name)
      .map { |obj| link_to(obj.name, items_path(category: obj.id)) }
      .join(", ")
  end

  def item_status_options
    explainations = {
      "pending" => "just acquired; not ready to loan",
      "active" => "available to loan",
      "maintenance" => "needs repair; do not loan",
      "retired" => "no longer part of our inventory"
    }
    Item.statuses.map do |key, value|
      ["#{key.titleize} (#{explainations[key]})", key]
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

  def rotated_variant(image, options = {})
    if image.metadata.key? "rotation"
      options[:rotate] ||= image.metadata["rotation"]
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
        ["label-warning", "Checked Out"]
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

  def item_status_class(item)
    if item.active?
      if item.checked_out_exclusive_loan
        "status-checked-out"
      elsif item.active_holds.count > 0
        "status-on-hold"
      else
        "status-available"
      end
    else
      "status-unavailable"
    end
  end

  def item_holds_label(item)
    if item.active?
      count = item.active_holds.size
      if count > 0
        tag.span pluralize(count, "hold"), class: "label item-hold-status"
      end
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
end
