module AdminHelper

  def index_header(title, &block)
    render "shared/index_header", title: title, &block
  end

end