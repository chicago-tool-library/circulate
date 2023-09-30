# frozen_string_literal: true

module PortalRendering
  def render_to_portal(partial, options = {})
    table_row = options.delete(:table_row)
    options[:layout] = table_row ? "portal_table_row" : nil
    options[:turbolinks] = false
    options[:partial] = partial
    render options
  end
end
