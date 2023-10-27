class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    item_scope = Item.listed_publicly.includes(:borrow_policy, :active_holds, :checked_out_exclusive_loan, :categories)

    item_scope = filter_by_category(item_scope) if filter_params[:category].present?
    item_scope = filter_by_query(item_scope) if filter_params[:query].present?
    item_scope = filter_by_available(item_scope) if filter_params[:available].present?

    # One of the filtering methods above may have already redirected
    return if performed?

    item_scope = item_scope.with_attached_image.order(index_order)

    set_index_page_title

    @categories = CategoryNode.with_items
    @pagy, @items = pagy(item_scope)
  end

  def show
    @item = Item.listed_publicly.find(params[:id])

    set_page_attr :title, "#{@item.name} (#{@item.complete_number})"

    if user_signed_in?
      @current_hold = current_member.active_holds.active.where(item_id: @item.id).first
      @current_hold_count = current_member.active_holds.active_hold_count_for_item(@item).to_i
    end
  end

  private

  def filter_params
    @filter_params ||= params.permit(:sort, :category, :query, :available).to_h.each_with_object({}) do |(k, v), filtered|
      value = v&.to_s&.strip&.presence

      next unless value

      filtered[k.to_sym] = value
    end
  end

  def set_index_page_title
    return unless @query || @category

    if @query
      title = "Search results for #{@query}"
      title << "in #{@category.name}" if @category
    else
      title = @category.name
    end

    set_page_attr(:title, title)
  end

  def filter_by_category(item_scope)
    @category = CategoryNode.find_by(id: params[:category])

    return filter_failed(:category, "Category not found") unless @category

    item_scope.for_category(@category)
  end

  def filter_by_query(item_scope)
    @query = filter_params[:query].to_s.strip.presence

    return item_scope unless @query

    if @query.size < 3
      flash.now[:warning] = "You must provide at least three numbers or letters to search by."
      filter_params.delete(:query)
      return item_scope
    end

    scope = item_scope.search_by_anything(@query)
    scope.select("#{scope.pg_search_rank_table_alias}.rank", "items.*")
  end

  def filter_by_available(item_scope)
    item_scope.available_now
  end

  def filter_failed(failed_param, error_message)
    filter_params = %i[sort category query].each_with_object({}) do |filter_param, accepted_params|
      next if filter_param == failed_param
      next if params[:filter_param].blank?

      accepted_params[filter_param] = params[filter_param]
    end

    redirect_to(items_path(filter_params), error: error_message)
  end

  def index_order
    options = {
      "name" => "items.name ASC",
      "number" => "items.number ASC",
      "added" => "items.created_at DESC"
    }
    options.fetch(params[:sort]) { options["added"] }
  end
end
