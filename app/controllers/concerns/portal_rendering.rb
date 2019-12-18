module PortalRendering
  def render_to_portal(partial, options = {})
    options[:layout] = nil
    options[:turbolinks] = false
    options[:partial] = partial
    render options
  end
end
