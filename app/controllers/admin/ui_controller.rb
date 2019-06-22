module Admin
  class UIController < BaseController
    def names
      names = Item
        .name_contains(params[:q])
        .pluck(:name)
        .map(&:humanize)
        .uniq
        .sort

      render json: names
    end

    def brands
      brands = Item
        .brand_contains(params[:q])
        .pluck(:brand)
        .uniq
        .sort

      render json: brands
    end
  end
end
