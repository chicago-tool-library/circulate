module IconsHelper
  def feather_icon(icon_name)
    tag.i(data: {feather: icon_name})
  end
end
