# frozen_string_literal: true

module Admin
  module Reports
    class MonthlyActivitiesController < BaseController
      def index
        fetch_monthly_activities
      end

      def fetch_monthly_activities
        @monthly_activities = {}

        # TODO: load_async in Rails 7
        appointments = MonthlyAppointment.all
        loans = MonthlyLoan.all
        members = MonthlyMember.all

        assign_monthlies(appointments, %i[appointments_count completed_appointments_count])
        assign_monthlies(loans, %i[loans_count active_members_count])
        assign_monthlies(members, %i[new_members_count pending_members_count])

        @monthly_activities = @monthly_activities.sort.to_h
      end

      def assign_monthlies(records, columns)
        records.each do |record|
          key = "#{record.year}-#{record.month.to_s.rjust(2, "0")}"
          monthly = @monthly_activities[key] ||= Hash.new(0)

          columns.each { |column| monthly[column] = record[column] }
        end
      end
    end
  end
end
