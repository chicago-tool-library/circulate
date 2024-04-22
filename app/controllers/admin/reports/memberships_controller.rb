require "csv"

module Admin
  module Reports
    class MembershipsController < BaseController
      include Pagy::Backend

      def index
        members_and_loan_counts = Member
          .open
          .left_joins(:loan_summaries)
          .select(:id, :email, :status, :full_name, :preferred_name, :library_id, "count(loan_summaries.initial_loan_id) as loans_count")
          .group("members.id", "members.email", "members.status", "members.full_name", "members.preferred_name")

        @members = Member
          .left_joins(memberships: :adjustment)
          .select("email", "members.id", "status", "full_name", "preferred_name", "loans_count",
            "count(memberships.id) as memberships_count",
            "max(memberships.ended_at) as expires_on",
            "array_agg(adjustments.amount_cents ORDER BY adjustments.created_at ASC) as amounts")
          .from(members_and_loan_counts, :members)
          .group("members.id", "members.email", "members.status", "members.full_name", "members.preferred_name", "loans_count")
          .order("expires_on ASC")

        respond_to do |format|
          format.html do
            @pagy, @members = pagy_arel(@members, items: 100)
          end

          format.csv do
            text = CSV.generate(headers: true) { |csv|
              csv << %w[preferred_name full_name email status loans expires_on count amount1 amount2 amount3]

              @members.find_each do |member|
                values = [member.preferred_name, member.full_name]
                values.concat member.attributes.values_at("email", "status", "loans_count")
                values << member.expires_on&.to_date
                values << member.memberships_count
                member.amounts.each do |amount|
                  values << Money.new(amount&.abs).format
                end
                csv << values
              end
            }

            filename = Time.current.strftime("memberships_%-m/%-d/%Y.csv")
            send_data text, filename: filename
          end
        end
      end
    end
  end
end
