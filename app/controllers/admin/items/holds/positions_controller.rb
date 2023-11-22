module Admin
  module Items
    module Holds
      class PositionsController < BaseController
        include PortalRendering

        def update
          @hold = @item.active_holds.find(params[:hold_id])
          @hold.insert_at(params[:position].to_i)

          @holds = @item.active_holds.ordered_by_position.includes(:member)

          respond_to do |format|
            format.turbo_stream {
              render turbo_stream: turbo_stream.replace("holds-list",
                render_to_string(partial: "admin/items/holds/list", locals: {holds: @holds}))
            }
          end
        end
      end
    end
  end
end
