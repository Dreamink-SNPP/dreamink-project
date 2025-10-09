class SequencesController < ApplicationController
  include ProjectAuthorization

  before_action :set_sequence, only: [ :edit, :update, :destroy ]
  before_action :set_act, only: [ :new, :create, :new_modal ]

  def index
    @sequences = @project.sequences.includes(:act).order('acts.position, sequences.position')
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

  def update
    respond_to do |format|
      if @sequence.update(sequence_params)
        format.turbo_stream do
          render turbo_stream: [
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
    act_id = @sequence.act_id
    @sequence.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("sequence_#{@sequence.id}"),
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
