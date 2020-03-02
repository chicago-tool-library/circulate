module ItemsHelper
  include Pagy::Frontend

  def item_tags(item)
    item.tags.map(&:name).sort.join(", ")
  end

  def item_status_options
    explainations = {
      "pending" => "just acquired; not ready to loan",
      "active" => "available to loan",
      "maintenance" => "needs repair; do not loan",
      "retired" => "no longer part of our inventory",
    }
    Item.statuses.map do |key, value|
      ["#{key.titleize} (#{explainations[key]})", key]
    end
  end

  def borrow_policy_options
    BorrowPolicy.alpha_by_code.map do |borrow_policy|
      ["(#{borrow_policy.code}) #{borrow_policy.name}: #{borrow_policy.description}", borrow_policy.id]
    end
  end

  def tag_nav(tags, current_tag = nil)
    return unless tags

    tag.div class: "nav tag-nav" do
      tags.map { |a_tag|
        tag.li(class: "nav-item #{"active" if a_tag == current_tag}") {
          link_to(a_tag.name, tag: a_tag.id)
        }
      }.join.html_safe
    end
  end

  def rotated_variant(image, options = {})
    if image.metadata.key? "rotation"
      options[:rotate] ||= image.metadata["rotation"]
    end
    image.variant(options)
  end

  def full_item_number(item)
    item.complete_number
  end

  def item_status_label(item)
    class_name, label = if item.active?
      if item.checked_out_exclusive_loan
        ["label-primary", "Checked Out"]
      else
        ["label-success", "Available"]
      end
    else
      ["", "Unavailable"]
    end
    tag.span label, class: "label item-checkout-status #{class_name}"
  end
end
