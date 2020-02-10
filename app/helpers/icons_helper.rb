module IconsHelper
  def feather_icon(icon_name, **options)
    opts = options.deep_merge({data: {feather: icon_name}})
    tag.i(**opts)
  end
end
