class SequencesController < ApplicationController
  include ProjectAuthorization

  before_action :set_sequence, only: [ :edit, :edit_modal, :update, :destroy, :move_to_act ]
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
          render turbo_stream: [
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

  def set_project
    @project = Project.find(params[:project_id])
  end
end
