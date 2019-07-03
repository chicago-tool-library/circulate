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

    def sizes
      sizes = Item
        .size_contains(params[:q])
        .pluck(:size)
        .uniq
        .sort

      render json: sizes
    end

    def strengths
      strengths = Item
        .strength_contains(params[:q])
        .pluck(:strength)
        .uniq
        .sort

      render json: strengths
    end


  end
end
