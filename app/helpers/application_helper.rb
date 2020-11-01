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

  def navbar_link_to(text, link, version = "")
    if version == "mobile"
      tag.span(class: "navbar-brand  mr-2 ml-2") do
        link_to(text, link)
      end
    else
      tag.li(class: "nav-item") do
        link_to(text, link)
      end
    end
  end
end
