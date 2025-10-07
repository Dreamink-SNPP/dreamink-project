class LocationsController < ApplicationController include ProjectAuthorization
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    @locations = @project.locations.order(:name)

    if params[:type].present? && %w[interior exterior].include?(params[:type])
      @locations = @locations.where(location_type: params[:type])
    end
  end

  def show
    @scenes = @location.scenes.includes(sequence: :act).order('acts.position, sequences.position, scenes.position')
  end

  def new
    @location = @project.locations.build
  end

  def create
    @location = @project.locations.build(location_params)

    if @location.save
      redirect_to project_locations_path(@project), notice: "Locación creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to project_locations_path(@project), notice: "Locación actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to project_locations_path(@project), notice: "Locación eliminada exitosamente"
  end
end
