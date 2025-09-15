module ApplicationHelper
  # Assume that any request with an action of new or edit is displaying a form
  def form_request?
    %w[new edit].include? params[:action]
  end

  def logo(library: current_library, small: false, classes: "", alt: "")
    if library.image.attached?
      image_tag url_for(library.image.variant(resize_to_limit: [100, 89])), class: classes, alt:
    else
      image_tag "logo#{"_small" if small}.png", class: classes, alt:
    end
  end

  def navbar_link_to(text, link, new_tab: false, **options)
    if new_tab
      options[:target] = "_blank"
      options[:rel] = "noopener noreferrer"
    end

    tag.li(class: "navigation-link") do
      link_to(text, link, class: "btn btn-link #{options.delete(:class)}", **options)
    end
  end

  def page_title
    if page_attr?(:title)
      "#{page_attr(:title)} - #{current_library.name}"
    else
      "#{current_library.name} Inventory"
    end
  end
end
