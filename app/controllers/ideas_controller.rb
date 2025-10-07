class IdeasController < ApplicationController
  include ProjectAuthorization

  before_action :set_idea, only: [ :edit, :update, :destroy ]

  def index
    @ideas = @project.ideas.recent

    if params[:tag].present?
      @ideas = @ideas.tagged_with(params[:tag])
    end
  end

  def new
    @idea = @project.ideas.build
  end

  def create
    @idea = @project.ideas.build(idea_params)

    if @idea.save
      redirect_to project_ideas_path(@project), notice: "Idea creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @idea.update(idea_params)
      redirect_to project_ideas_path(@project), notice: "Idea actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @idea.destroy
    redirect_to project_ideas_path(@project), notice: "Idea eliminada exitosamente"
  end

  def search
    @ideas = @project.ideas.recent

    if params[:q].present?
      @ideas = @ideas.search(params[:q])
    end

    render :index
  end

  private

  def set_idea
    @idea = @project.ideas.find(params[:id])
  end

  def idea_params
    params.require(:idea).permit(:title, :description, :tags)
  end
end
