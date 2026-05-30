module Admin
  module Items
    class SearchesController < Admin::BaseController
      include Pagy::Backend

      def show
        params[:q] ||= {}
        params[:q]["s"] ||= "number asc"
        params[:q]["status_in"] ||= %w[active pending maintenance]

        @search_query = ItemSearchQuery.new(params[:query])
        scope = Item.with_active_holds_count
        if @search_query.bare_terms.any?
          scope = scope.search_by_anything(@search_query.bare_terms.join(" "))
        end
        @search_query.field_constraints.each do |field, value|
          raise ArgumentError, "unsupported field" unless ItemSearchQuery::FIELDS.include?(field)
          escaped = ActiveRecord::Base.sanitize_sql_like(value)
          scope = scope.where("items.#{field} ILIKE ?", "%#{escaped}%")
        end

        @q = scope.ransack(params[:q])
        result = @q.result.includes(:categories, :borrow_policy).with_attached_image
        @pagy, @items = pagy(result)
      end
    end
  end
end
