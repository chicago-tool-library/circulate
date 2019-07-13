module Admin
  class TagsController < BaseController
    before_action :set_tag, only: [:show, :edit, :update, :destroy]

    # GET /tags
    # GET /tags.json
    def index
      @tags = Tag.sorted_by_name
    end

    # GET /tags/1
    # GET /tags/1.json
    def show
    end

    # GET /tags/new
    def new
      @tag = Tag.new
      set_all_tags
    end

    # GET /tags/1/edit
    def edit
      set_all_tags
    end

    # POST /tags
    # POST /tags.json
    def create
      @tag = Tag.new(tag_params)

      respond_to do |format|
        if @tag.save
          format.html { redirect_to admin_tags_url, success: "Tag was successfully created." }
          format.json { render :show, status: :created, location: @tag }
        else
          set_all_tags
          format.html { render :new }
          format.json { render json: @tag.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /tags/1
    # PATCH/PUT /tags/1.json
    def update
      respond_to do |format|
        if @tag.update(tag_params)
          format.html { redirect_to admin_tags_url, success: "Tag was successfully updated." }
          format.json { render :show, status: :ok, location: @tag }
        else
          set_all_tags
          format.html { render :edit }
          format.json { render json: @tag.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /tags/1
    # DELETE /tags/1.json
    def destroy
      @tag.destroy
      respond_to do |format|
        format.html { redirect_to admin_tags_url, warning: "Tag was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    def set_all_tags
      @all_tags = Tag.sorted_by_name
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end
