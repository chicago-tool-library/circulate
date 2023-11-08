module Admin
  class DocumentsController < BaseController
    before_action :set_document, only: [:show, :edit, :update]

    # GET /documents
    # GET /documents.json
    def index
      @documents = Document.all
    end

    # GET /documents/1
    # GET /documents/1.json
    def show
    end

    # GET /documents/1/edit
    def edit
    end

    # PATCH/PUT /documents/1
    # PATCH/PUT /documents/1.json
    def update
      respond_to do |format|
        if @document.update(document_params)
          format.html { redirect_to [:admin, @document], notice: "Document was successfully updated.", status: :see_other }
          format.json { render :show, status: :ok, location: [:admin, @document] }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @document.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.coded(params[:id]).first!
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:name, :summary, :body)
    end
  end
end
