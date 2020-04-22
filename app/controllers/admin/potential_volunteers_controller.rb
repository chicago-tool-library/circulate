require "csv"

module Admin
  class PotentialVolunteersController < BaseController
    def index
      @members = Member.volunteer.open.order(created_at: :desc)

      respond_to do |format|
        format.html
        format.csv do
          text = CSV.generate(headers: true) { |csv|
            csv << %w[email first_name phone_number created_at categories]

            @members.each do |user|
              values = user.attributes.values_at("email", "preferred_name", "phone_number", "created_at")
              values << "volunteer"
              csv << values
            end
          }

          filename = Time.current.strftime("potential_volunteers_%-m/%-d/%Y.csv")
          send_data text, filename: filename
        end
      end
    end
  end
end
