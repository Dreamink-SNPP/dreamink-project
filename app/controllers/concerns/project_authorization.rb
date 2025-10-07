module ProjectAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :set_project
    before_action :authorize_project!
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Proyecto no encontrado"
  end

  def authorize_project!
    unless @project.user_id == current_user.id
      redirect_to projects_path, alert: "No tienes permiso para acceder a este proyecto"
    end
  end
end