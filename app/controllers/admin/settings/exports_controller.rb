# frozen_string_literal: true

class Admin::Settings::ExportsController < Admin::BaseController
  include ActionController::Live

  def index
  end

  def items
    now = Time.current.rfc3339
    filename = "all-items-#{now}.csv"
    exporter = ItemExporter.new(Item.all)
    export(filename, exporter)
  end

  def members
    now = Time.current.rfc3339
    filename = "all-members-and-memberships-#{now}.csv"
    exporter = MemberExporter.new
    export(filename, exporter)
  end

  private
    def export(filename, exporter)
      send_file_headers!(
        type: "text/csv",
        disposition: "attachment",
        filename:
      )
      response.headers["Last-Modified"] = Time.now.httpdate
      exporter.export(response.stream)
    ensure
      response.stream.close
    end
end
