class LocationsController < ApplicationController
  include ProjectAuthorization

  before_action :set_location, only: [ :show, :edit, :update, :destroy ]

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

  def report
    @location = @project.locations.find(params[:id])

    pdf_generator = Pdf::LocationReportGenerator.new(@location)
    pdf_content = pdf_generator.generate

    send_data pdf_content,
      filename: "locacion_#{@location.name.parameterize}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end

  def collection_report
    pdf_generator = Pdf::LocationsCollectionReportGenerator.new(@project)
    pdf_content = pdf_generator.generate

    send_data pdf_content,
      filename: "locaciones_#{@project.title.parameterize}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end

  private

  def set_location
    @location = @project.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :description, :location_type)
  end
end
