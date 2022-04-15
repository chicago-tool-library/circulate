require "csv"

module Admin
  module Reports
    class ZipcodesController < BaseController
      def index
        @zipcodes = Member.open.select("postal_code, count(id)").group("postal_code").order("postal_code ASC").all

        respond_to do |format|
          format.html

          format.csv do
            text = CSV.generate(headers: true) { |csv|
              csv << %w[zipcode count]

              @zipcodes.each do |member|
                csv << [member.postal_code, member.count]
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
