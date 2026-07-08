module Admin
  module Items
    class SearchesController < Admin::BaseController
      include Pagy::Backend

      LONE_NUMBER_PATTERN = /\A(?:([A-Za-z]+)-?)?(\d+)\z/

      def show
        params[:q] ||= {}
        params[:q]["s"] ||= "number asc"
        params[:q]["status_in"] ||= %w[active pending maintenance]

        @search_query = ItemSearchQuery.new(params[:query])
        scope = Item.with_active_holds_count
        ransack_params = params[:q]

        if (exact = exact_match_for_lone_number_query(@search_query))
          scope = scope.where(items: {id: exact.id})
          ransack_params = ransack_params.except("status_in")
          @status_filter_ignored = true
        else
          if @search_query.bare_terms.any?
            normalized = @search_query.bare_terms.map { |term| strip_item_number_prefix(term) }
            scope = scope.search_by_anything(normalized.join(" "))
          end
          @search_query.field_constraints.each do |field, value|
            raise ArgumentError, "unsupported field" unless ItemSearchQuery::FIELDS.include?(field)
            scope = if field == "number"
              digits = strip_item_number_prefix(value)
              digits.match?(/\A\d+\z/) ? scope.where(items: {number: digits.to_i}) : scope.none
            else
              escaped = ActiveRecord::Base.sanitize_sql_like(value)
              scope.where("items.#{field} ILIKE ?", "%#{escaped}%")
            end
          end
        end

        @q = scope.ransack(ransack_params)
        result = @q.result.includes(:categories, :borrow_policy).with_attached_image
        @pagy, @items = pagy(result)
      end

      private

      def exact_match_for_lone_number_query(query)
        return nil unless query.field_constraints.empty?
        return nil unless query.bare_terms.size == 1
        match = query.bare_terms.first.match(LONE_NUMBER_PATTERN)
        return nil unless match

        relation = Item.where(number: match[2].to_i)
        relation = relation.joins(:borrow_policy).where(borrow_policies: {code: match[1].upcase}) if match[1]
        relation.first
      end

      def strip_item_number_prefix(term)
        (term =~ /\A[A-Za-z]+-?(\d+)\z/) ? $1 : term
      end
    end
  end
end
