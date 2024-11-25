module Admin
  module Reports
    module ItemsInMaintenanceHelper
      def sort_link(label, sort)
        link_to(
          label,
          admin_reports_items_in_maintenance_index_path(sort:, direction: direction_for_sort(sort)),
          class: sort_link_class_names(sort)
        )
      end

      private

      def sort_link_class_names(sort)
        class_names = %w[sort-link]

        if current_sort == sort
          class_names << "current"
          class_names << current_direction
        end

        class_names.join(" ")
      end

      def direction_for_sort(sort)
        if current_sort == sort && current_direction == "asc"
          "desc"
        else
          "asc"
        end
      end

      def current_sort
        params[:sort] || "ticket-created_at"
      end

      def current_direction
        params[:direction] || "desc"
      end
    end
  end
end
