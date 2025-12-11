module Admin
  class UIController < BaseController
    def names
      names = Item
        .name_contains(params[:q])
        .pluck(:name)
        .map(&:strip)
        .map(&:humanize)
        .uniq
        .sort

      render json: names
    end

    def brands
      brands = Item
        .brand_contains(params[:q])
        .pluck(:brand)
        .map(&:strip)
        .uniq
        .sort

      render json: brands
    end

    def sizes
      sizes = Item
        .size_contains(params[:q])
        .pluck(:size)
        .map(&:strip)
        .uniq
        .sort

      render json: sizes
    end

    def strengths
      strengths = Item
        .strength_contains(params[:q])
        .pluck(:strength)
        .map(&:strip)
        .uniq
        .sort

      render json: strengths
    end

    def available_items
      items = Item
        .available
        .includes(:borrow_policy)
        .search_by_anything(params[:q])
        .by_name
        .limit(20)
        .map(&:complete_number_and_name)

      render json: items
    end

    def members
      members = Member
        .matching(params[:q])
        .open
        .map { |m| {label: helpers.preferred_or_default_name(m), value: m.id} }

      render json: members
    end
  end
end
