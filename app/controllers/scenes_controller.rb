class ScenesController < ApplicationController
  include ProjectAuthorization

  before_action :set_scene, only: [ :show, :edit, :edit_modal, :update, :destroy, :move_to_sequence ]
  before_action :set_sequence, only: [ :new, :create, :new_modal ]

  def index
    @scenes = @project.scenes.includes(sequence: :act).order("acts.position, sequences.position, scenes.position")
  end

  def show
  end

  def new
    @scene = @sequence.scenes.build
    @locations = @project.locations.order(:name)
  end

  def create
    @scene = @sequence.scenes.build(scene_params)

    respond_to do |format|
      if @scene.save
        # Actualizar locaciones si fueron seleccionadas
        if params[:scene][:location_ids].present?
          @scene.location_ids = params[:scene][:location_ids].reject(&:blank?)
        end

        format.turbo_stream do
          render turbo_stream: [
            # Agregar la nueva escena a la secuencia
            turbo_stream.append("sequence_#{@sequence.id}_scenes",
                                partial: "structures/scene_item",
                                locals: { scene: @scene, project: @project }
            ),
            # Mostrar éxito en el modal
            turbo_stream.update("new_scene_modal_content",
                                partial: "scenes/success"
            ),
            # Mensaje flash
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Escena creada exitosamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Escena creada exitosamente" }
      else
        @locations = @project.locations.order(:name)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("scene_form",
                                                    partial: "scenes/form",
                                                    locals: { scene: @scene }
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @locations = @project.locations.order(:name)
  end

  def edit_modal
    @locations = @project.locations.order(:name)
    render partial: "scenes/form", locals: { scene: @scene }, layout: false
  end

  def update
    respond_to do |format|
      if @scene.update(scene_params)
        # Actualizar locaciones
        if params[:scene][:location_ids].present?
          @scene.location_ids = params[:scene][:location_ids].reject(&:blank?)
        end

        format.turbo_stream do
          render turbo_stream: [
            # Cerrar el modal mostrando éxito
            turbo_stream.update("edit_scene_modal_content",
                                partial: "scenes/success_edit"
            ),
            turbo_stream.replace("scene_#{@scene.id}",
                                 partial: "structures/scene_item",
                                 locals: { scene: @scene, project: @project }
            ),
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Escena actualizada exitosamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Escena actualizada exitosamente" }
      else
        @locations = @project.locations.order(:name)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("scene_form",
                                                    partial: "scenes/form",
                                                    locals: { scene: @scene }
          )
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @scene.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("scene_#{@scene.id}"),
          turbo_stream.prepend("flash_messages",
                               partial: "shared/flash_notice",
                               locals: { message: "Escena eliminada exitosamente" }
          )
        ]
      end
      format.html { redirect_to project_structure_path(@project), notice: "Escena eliminada exitosamente" }
    end
  end

  def by_location
    @location = @project.locations.find(params[:location_id])
    @scenes = @location.scenes.includes(sequence: :act).order("acts.position, sequences.position, scenes.position")
  end

  def new_modal
    @scene = @sequence.scenes.build
    @locations = @project.locations.order(:name)
    render partial: "scenes/form", locals: { scene: @scene }, layout: false
  end

  def move_to_sequence
      target_sequence_id = params[:target_sequence_id]
      target_position = params[:target_position]&.to_i

      if target_sequence_id.blank?
        return render json: { error: "target_sequence_id is required" }, status: :bad_request
      end

      target_sequence = @project.sequences.find_by(id: target_sequence_id)

      if target_sequence.nil?
        return render json: { error: "Target sequence not found" }, status: :not_found
      end

      if @scene.move_to_sequence(target_sequence, new_position: target_position)
        respond_to do |format|
          format.turbo_stream do
            redirect_to project_structure_path(@project)
          end
          format.json do
            render json: {
              success: true,
              scene_id: @scene.id,
              new_sequence_id: target_sequence.id,
              new_position: @scene.position
            }, status: :ok
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.prepend("flash_messages",
              partial: "shared/flash_alert",
              locals: { message: "Error al mover la escena" }
            )
          end
          format.json do
            render json: { error: "Failed to move scene" }, status: :unprocessable_entity
          end
        end
      end
    end

  private

  def set_scene
    @scene = @project.scenes.find(params[:id])
  end

  def set_sequence
    sequence_id = params[:sequence_id] || params.dig(:scene, :sequence_id)
    @sequence = @project.sequences.find(sequence_id) if sequence_id
  end

  def scene_params
    params.require(:scene).permit(:title, :description, :color, :position, :sequence_id)
  end
end
