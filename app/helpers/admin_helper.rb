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

end