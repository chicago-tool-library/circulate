# frozen_string_literal: true

module LayoutHelper
  def section_header(title, level: "h1", &block)
    right_content = block ? capture(&block) : ""
    content_tag(:div, class: "section-header") do
      content_tag(level, title, class: "section-header-title") +
        content_tag(:div, right_content, class: "section-header-content")
    end
  end
end
