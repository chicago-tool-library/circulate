require "csv"

module Admin
  module Reports
    class ZipcodesController < BaseController
      def index
        @data = Member.open.group(:postal_code).order(:postal_code).count
        respond_to do |format|
          format.html

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
