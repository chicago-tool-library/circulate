module ApplicationHelper
  # Assume that any request with an action of new or edit is displaying a form
  def form_request?
    %w[new edit].include? params[:action]
  end

  def portal(&block)
    attrs = {
      data: {
        controller: "portal",
        action: "ajax:error->portal#replaceContent ajax:success->portal#replaceContent"
      }
    }
    tag.div(**attrs, &block)
  end

  def logo(library: current_library, small: false, classes: "")
    if library.image.attached?
      image_tag url_for(library.image.variant(resize_to_limit: [100, 89])), class: classes
    else
      image_pack_tag "logo#{small ? '_small' : nil}.png", class: classes
    end
  end
end
