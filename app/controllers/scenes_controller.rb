class ScenesController < ApplicationController include ProjectAuthorization
  before_action :set_scene, only: [:show, :edit, :update, :destroy, :move]
  before_action :set_sequence, only: [:new, :create]

  def index
    @scenes = @project.scenes.includes(sequence: :act).order('acts.position, sequences.position, scenes.position')
  end

  def show
  end

  def new
    @scene = @sequence.scenes.build
    @locations = @project.locations.order(:name)
  end

  def create
    @scene = @sequence.scenes.build(scene_params)

    if @scene.save
      # Asociar locaciones si fueron seleccionadas
      if params[:scene][:location_ids].present?
        @scene.location_ids = params[:scene][:location_ids].reject(&:blank?)
      end

      redirect_to project_structure_path(@project), notice: "Escena creada exitosamente"
    else
      @locations = @project.locations.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @locations = @project.locations.order(:name)
  end

  def update
    if @scene.update(scene_params)
      # Actualizar locaciones
      if params[:scene][:location_ids].present?
        @scene.location_ids = params[:scene][:location_ids].reject(&:blank?)
      end

      redirect_to project_structure_path(@project), notice: "Escena actualizada exitosamente"
    else
      @locations = @project.locations.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @scene.destroy
    redirect_to project_structure_path(@project), notice: "Escena eliminada exitosamente"
  end

  def move
    new_position = params[:position].to_i
    @scene.insert_at(new_position)
    head :ok
  end

  def by_location
    @location = @project.locations.find(params[:location_id])
    @scenes = @location.scenes.includes(sequence: :act).order('acts.position, sequences.position, scenes.position')
  end
end
