# frozen_string_literal: true

ReverseMarkdown::Converters.unregister :strong

class HTMLToMarkdown
  def convert(html)
    ReverseMarkdown.convert(html, unknown_tags: :bypass)
  end
end
