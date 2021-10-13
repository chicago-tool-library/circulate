module PortalRendering
  def render_to_portal(partial, options = {})
    table_row = options.delete(:table_row)
    options[:layout] = table_row ? "portal_table_row" : nil
    options[:turbo] = false
    options[:partial] = partial
    render options
  end
end
