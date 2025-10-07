class ActsController < ApplicationController include ProjectAuthorization
  before_action :set_act, only: [:edit, :update, :destroy, :move]

  def index
    @acts = @project.acts.ordered
  end

  def new
    @act = @project.acts.build
  end

  def create
    @act = @project.acts.build(act_params)

    if @act.save
      redirect_to project_structure_path(@project), notice: "Acto creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @act.update(act_params)
      redirect_to project_structure_path(@project), notice: "Acto actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @act.destroy
    redirect_to project_structure_path(@project), notice: "Acto eliminado exitosamente"
  end
end
