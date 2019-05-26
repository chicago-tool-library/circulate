module AdminHelper
  def index_header(title, &block)
    render "shared/index_header", title: title, &block
  end

  def flash_message(key)
    if flash.key?(key)
      tag.div(class: "toast toast-#{key}", data: {controller: "alert"}) do
        tag.button(class:"btn btn-clear float-right", data: {action: "alert#remove"}) + flash[key]
      end
    end
  end

  def empty_state(title, subtitle:nil, icon:nil, &block)
    render "shared/empty_state", title: title, subtitle: subtitle, icon:icon, &block
  end
end