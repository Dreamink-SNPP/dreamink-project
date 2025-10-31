class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :report ]
  before_action :authorize_project!, only: [ :show, :edit, :update, :destroy, :report ]

  def index
    @projects = current_user.projects.order(updated_at: :desc)
  end

  def show
    # Vista detallada del tratamiento
  end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.build(project_params)

    if @project.save
      redirect_to @project, notice: "Proyecto creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Proyecto actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Proyecto eliminado exitosamente"
  end

  # Generar PDF del tratamiento del proyecto
  def report
    pdf_generator = Pdf::ProjectReportGenerator.new(@project)
    pdf_content = pdf_generator.generate

    send_data pdf_content,
      filename: "tratamiento_#{@project.title.parameterize}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Proyecto no encontrado"
  end

  def authorize_project!
    unless @project.user_id == current_user.id
      redirect_to projects_path, alert: "No tienes permiso para acceder a este proyecto"
    end
  end

  def project_params
    params.require(:project).permit(
      :title, :genre, :idea, :logline, :storyline,
      :short_synopsis, :long_synopsis, :world,
      :characters_summary, :themes, :tone
    )
  end
end
