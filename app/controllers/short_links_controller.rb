class ShortLinksController < ApplicationController
  def show
    @short_link = ShortLink.where(slug: params[:id]).first
    if @short_link
      redirect_to @short_link.url, status: :moved_permanently
    else
      render_not_found
    end
  end
end
