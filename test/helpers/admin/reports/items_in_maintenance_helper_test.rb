require "test_helper"

module Admin
  module Reports
    class ItemsInMaintenanceHelperTest < ActionView::TestCase
      test "sort_link builds a link to the items in mainteance index path" do
        result = sort_link("Number", "item-number")
        assert_includes result, ">Number<"
        assert_includes result, "<a "
        assert_includes result, %(href="#{admin_reports_items_in_maintenance_index_path})
        assert_includes result, "sort=item-number"
        assert_includes result, "direction=asc"
      end

      test "sort_link builds a link with the correct direction" do
        assert_includes sort_link("Number", "item-number"), "direction=asc"

        params[:sort] = "item-number"
        params[:direction] = "asc"
        assert_includes sort_link("Number", "item-number"), "direction=desc"

        params[:sort] = "item-number"
        params[:direction] = "desc"
        assert_includes sort_link("Number", "item-number"), "direction=asc"
      end

      test "sort_link builds a link with the correct classes" do
        assert_includes sort_link("Number", "item-number"), %(class="sort-link")

        params[:sort] = "item-number"
        params[:direction] = "asc"
        assert_includes sort_link("Number", "item-number"), %(class="sort-link current asc")

        params[:sort] = "item-number"
        params[:direction] = "desc"
        assert_includes sort_link("Number", "item-number"), %(class="sort-link current desc")
      end
    end
  end
end
