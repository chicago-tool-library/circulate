# PageAttributes provides a consise API for declaring bits of page metadata
# within controller methods, stored as a Hash on the controller instance.
#
# These values can be retrieved in views using the same method.
module PageAttributes
  def self.included(base)
    base.helper_method :page_attr
    base.helper_method :page_attr?
  end

  private

  def set_page_attr(key, value)
    @page_attributes ||= {}
    @page_attributes[key] = value
    value
  end

  def page_attr(key)
    @page_attributes ||= {}
    @page_attributes[key]
  end

  def page_attr?(key)
    @page_attributes&.has_key?(key)
  end
end
