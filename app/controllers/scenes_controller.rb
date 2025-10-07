class ScenesController < ApplicationController
  include ProjectAuthorization

  before_action :set_scene, only: [ :show, :edit, :update, :destroy, :move ]
  before_action :set_sequence, only: [ :new, :create ]

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

  def new_modal
    @scene = @sequence.scenes.build
    render partial: "scenes/form", locals: { scene: @scene }, layout: false
  end

  private

  def set_scene
    @scene = @project.scenes.find(params[:id])
  end

  def set_sequence
    @sequence = @project.sequences.find(params[:sequence_id])
  end

  def scene_params
    params.require(:scene).permit(:title, :description, :color, :position, :sequence_id)
  end
end
