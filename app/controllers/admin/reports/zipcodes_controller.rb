require "csv"

module Admin
  module Reports
    class ZipcodesController < BaseController
      def index
        @data = Member.open.where("TRIM(postal_code) ~ '[0-9]{5}'").group(:postal_code).order(count_all: :desc).count
        respond_to do |format|
          format.html do
            @inline_svg = Map::Chicago.new(@data).to_xml
          end

          format.csv do
            text = CSV.generate(headers: true) { |csv|
              csv << %w[zipcode count]

              @data.each do |postal_code, count|
                csv << [postal_code, count]
              end
            }

            filename = Time.current.strftime("zipcodes_%-m/%-d/%Y.csv")
            send_data text, filename: filename
          end
        end
      end
    end
  end
end
