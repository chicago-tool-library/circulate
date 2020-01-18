module IconsHelper
  # Trying to do this with the tag helper got messy. SVG is sensitive to whitespace and the
  # tag helper doesn't handle namespaced attributes properly.
  def feather_icon(icon_name)
    %(<svg class="feather-icon">
      <use xlink:href="#{asset_pack_path("media/dist/feather-sprite.svg")}##{icon_name}"/>
    </svg>).html_safe
  end
end
