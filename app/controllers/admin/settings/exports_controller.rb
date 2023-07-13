class Admin::Settings::ExportsController < Admin::BaseController
  include ActionController::Live

  def index
  end

  def create
    now = Time.current.rfc3339
    filename = "all-items-#{now}.csv"

    send_file_headers!(
      type: "text/csv",
      disposition: "attachment",
      filename: filename
    )
    response.headers["Last-Modified"] = Time.now.httpdate

    exporter = ItemExporter.new(Item.all)
    exporter.export(response.stream)
  ensure
    response.stream.close
  end
end
