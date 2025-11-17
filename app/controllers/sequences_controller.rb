class SequencesController < ApplicationController
  include ProjectAuthorization

  before_action :set_sequence, only: [ :edit, :edit_modal, :update, :destroy, :move_to_act, :move_left, :move_right ]
  before_action :set_act, only: [ :new, :create, :new_modal ]

  def index
    @sequences = @project.sequences.includes(:act).order("acts.position, sequences.position")
  end

  def new
    @sequence = @act.sequences.build
  end

  def create
    @sequence = @act.sequences.build(sequence_params)

    respond_to do |format|
      if @sequence.save
        format.turbo_stream do
          streams = [
            # Agregar la nueva secuencia al acto
            turbo_stream.append("act_#{@act.id}_sequences",
                                partial: "structures/sequence_card",
                                locals: { sequence: @sequence, project: @project }
            ),
            # Limpiar el formulario o cerrar modal
            turbo_stream.update("new_sequence_modal_content",
                                partial: "sequences/success"
            ),
            # Actualizar contador del acto
            turbo_stream.update("act_#{@act.id}_stats",
                                partial: "structures/act_stats",
                                locals: { act: @act }
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
                                 locals: { message: "Secuencia creada exitosamente" }
            )
          ]

          # Remover el mensaje "Sin secuencias" si esta es la primera
          if @act.sequences.count == 1
            streams << turbo_stream.remove("act_#{@act.id}_empty_state")
          end

          render turbo_stream: streams
        end
        format.html { redirect_to project_structure_path(@project), notice: "Secuencia creada exitosamente" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("sequence_form",
                                                    partial: "sequences/form",
                                                    locals: { sequence: @sequence }
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def edit_modal
    render partial: "sequences/form", locals: { sequence: @sequence }, layout: false
  end

  def update
    respond_to do |format|
      if @sequence.update(sequence_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("edit_sequence_modal_content",
                                partial: "sequences/success_edit"
            ),
            turbo_stream.replace("sequence_#{@sequence.id}",
                                 partial: "structures/sequence_card",
                                 locals: { sequence: @sequence, project: @project }
            ),
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Secuencia actualizada exitosamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Secuencia actualizada exitosamente" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("sequence_form",
                                                    partial: "sequences/form",
                                                    locals: { sequence: @sequence }
          )
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    act = @sequence.act
    @sequence.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("sequence_#{@sequence.id}"),
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
                               locals: { message: "Secuencia eliminada exitosamente" }
          )
        ]
      end
      format.html { redirect_to project_structure_path(@project), notice: "Secuencia eliminada exitosamente" }
    end
  end

  def new_modal
    @act = @project.acts.find(params[:act_id])
    @sequence = @act.sequences.build
    render partial: "sequences/form", locals: { sequence: @sequence }, layout: false
  end

  def move_to_act
    target_act_id = params[:target_act_id]
    target_position = params[:target_position]&.to_i

    if target_act_id.blank?
      return render json: { error: "target_act_id is required" }, status: :bad_request
    end

  target_act = @project.acts.find_by(id: target_act_id)

    if target_act.nil?
      return render json: { error: "Target act not found" }, status: :not_found
    end

    if @sequence.move_to_act(target_act, new_position: target_position)
      respond_to do |format|
        format.turbo_stream do
          redirect_to project_structure_path(@project), notice: "Secuencia movida exitosamente"
        end
        format.json do
          render json: {
            success: true,
            sequence_id: @sequence.id,
            new_act_id: target_act.id,
            new_position: @sequence.position
          }, status: :ok
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash_messages",
            partial: "shared/flash_alert",
            locals: { message: "Error al mover la secuencia" }
          )
        end
        format.json do
          render json: { error: "Failed to move sequence" }, status: :unprocessable_entity
        end
      end
    end
  end

  # Mover secuencia hacia arriba (decrementar posición)
  def move_left
    act = @sequence.act
    target_sequence = act.sequences.find_by(position: @sequence.position - 1)

    respond_to do |format|
      if target_sequence
        swap_positions(@sequence, target_sequence)
        format.turbo_stream do
          render turbo_stream: [
            # Reemplazar la lista de secuencias del acto para reflejar el nuevo orden
            turbo_stream.update("act_#{act.id}_sequences",
                                partial: "structures/sequences_list",
                                locals: { act: act, project: @project }
            ),
            # Mensaje flash
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Secuencia movida correctamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Secuencia movida correctamente" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash_messages",
                                                    partial: "shared/flash_alert",
                                                    locals: { message: "La secuencia ya está en la primera posición" }
          )
        end
        format.html { redirect_to project_structure_path(@project), alert: "La secuencia ya está en la primera posición" }
      end
    end
  end

  # Mover secuencia hacia abajo (incrementar posición)
  def move_right
    act = @sequence.act
    target_sequence = act.sequences.find_by(position: @sequence.position + 1)

    respond_to do |format|
      if target_sequence
        swap_positions(@sequence, target_sequence)
        format.turbo_stream do
          render turbo_stream: [
            # Reemplazar la lista de secuencias del acto para reflejar el nuevo orden
            turbo_stream.update("act_#{act.id}_sequences",
                                partial: "structures/sequences_list",
                                locals: { act: act, project: @project }
            ),
            # Mensaje flash
            turbo_stream.prepend("flash_messages",
                                 partial: "shared/flash_notice",
                                 locals: { message: "Secuencia movida correctamente" }
            )
          ]
        end
        format.html { redirect_to project_structure_path(@project), notice: "Secuencia movida correctamente" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash_messages",
                                                    partial: "shared/flash_alert",
                                                    locals: { message: "La secuencia ya está en la última posición" }
          )
        end
        format.html { redirect_to project_structure_path(@project), alert: "La secuencia ya está en la última posición" }
      end
    end
  end

  private

  def set_sequence
    @sequence = @project.sequences.find(params[:id]) if params[:id]
  end

  def set_act
    act_id = params[:act_id] || params.dig(:sequence, :act_id)
    @act = @project.acts.find(act_id) if act_id
  end

  def sequence_params
    params.require(:sequence).permit(:title, :description, :position, :act_id)
  end

  # Intercambiar posiciones de dos secuencias evitando el unique constraint
  def swap_positions(sequence1, sequence2)
    # Guardar posiciones originales
    pos1 = sequence1.position
    pos2 = sequence2.position

    ActiveRecord::Base.transaction do
      # Paso 1: Mover a posiciones temporales negativas
      # Using update_column to bypass validations and callbacks for performance
      # and to avoid triggering unique constraint violations during swap
      sequence1.update_column(:position, -1000)
      sequence2.update_column(:position, -1001)

      # Paso 2: Asignar las posiciones intercambiadas
      sequence1.update_column(:position, pos2)
      sequence2.update_column(:position, pos1)
    end

    Rails.logger.info "Swapped sequences #{sequence1.id} and #{sequence2.id}"
  end
end
