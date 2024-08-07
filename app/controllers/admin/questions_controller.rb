class Admin::QuestionsController < Admin::BaseController
  before_action :set_question, only: %i[show edit update archive unarchive]

  # GET /admin/questions or /admin/questions.json
  def index
    @questions = Question.all.includes(:stem).order(:name)
  end

  # GET /admin/questions/1 or /admin/questions/1.json
  def show
  end

  # GET /admin/questions/new
  def new
    @question = Question.new
    @stem = Stem.new
  end

  # GET /admin/questions/1/edit
  def edit
    @stem = @question.stem.presence || Stem.new
  end

  # POST /admin/questions or /admin/questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to admin_question_url(@question), success: "Question was successfully created." }
        format.json { render :show, status: :created, location: @question }
      else
        @stem = @question.stems.find_or_initialize_by(stem_params)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/questions/1 or /admin/questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to admin_question_url(@question), success: "Question was successfully updated." }
        format.json { render :show, status: :ok, location: @question }
      else
        @stem = @question.stems.find_or_initialize_by(stem_params)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @question.update!(archived_at: Time.current)
    redirect_to admin_question_path(@question), success: "Question was successfully archived."
  end

  def unarchive
    @question.update!(archived_at: nil)
    redirect_to admin_question_path(@question), success: "Question was successfully unarchived."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_question
    @question = Question.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def question_params
    params.require(:question).permit(:name, stems_attributes: [:answer_type, :content])
  end

  def stem_params
    {
      answer_type: question_params.dig(:stems_attributes, 0, :answer_type),
      content: question_params.dig(:stems_attributes, 0, :content)
    }
  end
end
