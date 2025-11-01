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
          streams = [
            # Agregar la nueva escena a la secuencia
            turbo_stream.append("sequence_#{@sequence.id}_scenes",
                                partial: "structures/scene_item",
                                locals: { scene: @scene, project: @project }
            ),
            # Mostrar éxito en el modal
            turbo_stream.update("new_scene_modal_content",
                                partial: "scenes/success"
            ),
            # Actualizar contador de la secuencia
            turbo_stream.update("sequence_#{@sequence.id}_stats",
                                partial: "structures/sequence_stats",
                                locals: { sequence: @sequence }
            ),
            # Actualizar contador del acto
            turbo_stream.update("act_#{@sequence.act.id}_stats",
                                partial: "structures/act_stats",
                                locals: { act: @sequence.act }
            ),
            # Actualizar estadísticas
            turbo_stream.update("statistics_counters",
                                partial: "structures/statistics",
                                locals: {
                                  acts_count: @project.acts.count,
                                  sequences_count: @project.sequences.count,
                                  scenes_count: @project.scenes.count
                                }
            ),
            # Mensaje flash
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Escena creada exitosamente" }
            )
          ]

          # Remover el mensaje "Sin escenas" si esta es la primera
          if @sequence.scenes.count == 1
            streams << turbo_stream.remove("sequence_#{@sequence.id}_empty_state")
          end

          render turbo_stream: streams
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
    sequence = @scene.sequence
    act = sequence.act
    @scene.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("scene_#{@scene.id}"),
          # Actualizar contador de la secuencia
          turbo_stream.update("sequence_#{sequence.id}_stats",
                              partial: "structures/sequence_stats",
                              locals: { sequence: sequence }
          ),
          # Actualizar contador del acto
          turbo_stream.update("act_#{act.id}_stats",
                              partial: "structures/act_stats",
                              locals: { act: act }
          ),
          # Actualizar estadísticas
          turbo_stream.update("statistics_counters",
                              partial: "structures/statistics",
                              locals: {
                                acts_count: @project.acts.count,
                                sequences_count: @project.sequences.count,
                                scenes_count: @project.scenes.count
                              }
          ),
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
      old_sequence = @scene.sequence
      old_act = old_sequence.act

      if target_sequence_id.blank?
        return render json: { error: "target_sequence_id is required" }, status: :bad_request
      end

      target_sequence = @project.sequences.find_by(id: target_sequence_id)

      if target_sequence.nil?
        return render json: { error: "Target sequence not found" }, status: :not_found
      end

      if @scene.move_to_sequence(target_sequence, new_position: target_position)
        new_act = target_sequence.act

        respond_to do |format|
          format.turbo_stream do
            streams = [
              # Remove scene from old sequence
              turbo_stream.remove("scene_#{@scene.id}"),
              # Update old sequence stats
              turbo_stream.update("sequence_#{old_sequence.id}_stats",
                                  partial: "structures/sequence_stats",
                                  locals: { sequence: old_sequence }),
              # Update new sequence stats
              turbo_stream.update("sequence_#{target_sequence.id}_stats",
                                  partial: "structures/sequence_stats",
                                  locals: { sequence: target_sequence }),
              # Update old act stats
              turbo_stream.update("act_#{old_act.id}_stats",
                                  partial: "structures/act_stats",
                                  locals: { act: old_act }),
              # Flash message
              turbo_stream.prepend("flash_messages",
                                   partial: "shared/flash_notice",
                                   locals: { message: "Escena movida correctamente" })
            ]

            # Add scene to new sequence at correct position
            if @scene.position == 1
              # If position is 1, prepend (add to beginning)
              streams << turbo_stream.prepend("sequence_#{target_sequence.id}_scenes",
                                              partial: "structures/scene_item",
                                              locals: { scene: @scene, project: @project })
            else
              # For other positions, we need to insert at the right place
              # Find the scene that should come before this one
              previous_scene = target_sequence.scenes.where("position < ?", @scene.position)
                                                     .order(position: :desc).first

              if previous_scene
                streams << turbo_stream.after("scene_#{previous_scene.id}",
                                              partial: "structures/scene_item",
                                              locals: { scene: @scene, project: @project })
              else
                # Fallback to append if we can't find previous scene
                streams << turbo_stream.append("sequence_#{target_sequence.id}_scenes",
                                               partial: "structures/scene_item",
                                               locals: { scene: @scene, project: @project })
              end
            end

            # Update new act stats if different from old act
            if new_act.id != old_act.id
              streams << turbo_stream.update("act_#{new_act.id}_stats",
                                            partial: "structures/act_stats",
                                            locals: { act: new_act })
            end

            # Remove empty state from new sequence if this is the first scene
            if target_sequence.scenes.count == 1
              streams << turbo_stream.remove("sequence_#{target_sequence.id}_empty_state")
            end

            render turbo_stream: streams
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
    @sequence = Sequence.find(sequence_id) if sequence_id
    # Ensure sequence belongs to current project
    if @sequence && @sequence.act.project_id != @project.id
      @sequence = nil
    end
  end

  def scene_params
    params.require(:scene).permit(:title, :description, :color, :position, :sequence_id)
  end
end
