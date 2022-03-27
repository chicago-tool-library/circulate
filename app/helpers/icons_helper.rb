module IconsHelper
  def feather_icon(icon_name, **options)
    opts = options.deep_merge({data: {feather: icon_name}})
    tag.i(**opts)
  end

  def icon_stat(icon_name, content = nil, css_class: nil, title: nil, placeholder: nil, &block)
    content = capture(&block) if block
    return if content.blank? && placeholder.nil?

    tag.li(title: title, class: css_class, placeholder: placeholder) do
      if content.blank?
        tag.i(data: {feather: icon_name}) + tag.span(placeholder, class: "placeholder-text")
      else
        tag.i(data: {feather: icon_name}) + content.to_s
      end
    end
  end
end
