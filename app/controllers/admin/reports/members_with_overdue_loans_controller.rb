require "csv"

module Admin
  module Reports
    class MembersWithOverdueLoansController < BaseController
      include Pagy::Backend
      include ActionView::Helpers::DateHelper

      def index
        query = build_query

        respond_to do |format|
          format.html do
            @pagy, @members = pagy_arel(query, items: 100)
          end
          format.csv do
            filename = Time.current.strftime("members_with_overdue_loans_%-m/%-d/%Y.csv")
            send_data build_csv(query), filename:
          end
        end
      end

      private

      def build_query
        overdue_loan_min = Loan.arel_table[:due_at].minimum.as("overdue_loan_min")

        loans_query = Loan.overdue

        if params[:borrow_policy_id]
          loans_query = loans_query.joins(:item).where(item: { borrow_policy_id: params[:borrow_policy_id]})
        end

        Member.all
          .where(id: loans_query.select(:member_id))
          .joins(:overdue_loans)
          .group(:id)
          .includes(:user, overdue_loans: :item)
          .select(:id, :user_id, :preferred_name, :full_name, :phone_number, overdue_loan_min)
          .order(overdue_loan_min: :asc)
      end

      def build_csv(members)
        CSV.generate(headers: true) do |csv|
          csv << %w[preferred_name full_name email phone_number overdue_tools]

          members.find_each do |member|
            csv << [
              member.preferred_name,
              member.full_name,
              member.user.email,
              member.phone_number,
              member.overdue_loans.map { |loan| "#{loan.item.name} (#{time_ago_in_words(loan.due_at)})" }.join(", ")
            ]
          end
        end
      end
    end
  end
end
