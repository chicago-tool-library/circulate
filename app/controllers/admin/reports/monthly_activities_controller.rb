module Admin
  module Reports
    class MonthlyActivitiesController < BaseController
      def index
        @monthly_activities = fetch_activities
      end

      private

      def fetch_activities
        records = [*MonthlyAppointment.all, *MonthlyLoan.all, *MonthlyMember.all, *MonthlyRenewal.all]

        records.group_by(&:year).each_with_object([]) do |(year, records_for_year), grouped_year|
          monthly_values = records_for_year.group_by(&:month).each_with_object([]) do |(month, records_for_month), grouped_month|
            grouped_month << [month, records_to_amount_hash(records_for_month)]
          end

          grouped_year << [year, monthly_values.sort_by(&:first)]
        end.sort_by(&:first)
      end

      def columns_for_record(record)
        case record
        when MonthlyAppointment
          %i[appointments_count completed_appointments_count]
        when MonthlyLoan
          %i[loans_count active_members_count]
        when MonthlyMember
          %i[new_members_count pending_members_count]
        when MonthlyRenewal
          %i[renewals_count]
        else
          raise "Unknow record type: #{record}"
        end
      end

      def records_to_amount_hash(records)
        records.each_with_object(Hash.new(0)) do |record, hash|
          columns_for_record(record).each do |column|
            hash[column] = record[column]
          end
        end
      end
    end
  end
end
