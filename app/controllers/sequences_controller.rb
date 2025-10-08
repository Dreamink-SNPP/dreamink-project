class SequencesController < ApplicationController
  include ProjectAuthorization

  before_action :set_sequence, only: [ :edit, :update, :destroy, :move ]
  before_action :set_act, only: [ :new, :create, :new_modal ]

  def index
    @sequences = @project.sequences.includes(:act).order('acts.position, sequences.position')
  end

  def new
    @sequence = @act.sequences.build
  end

  def create
    @sequence = @act.sequences.build(sequence_params)

    if @sequence.save
      redirect_to project_structure_path(@project), notice: "Secuencia creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @sequence.update(sequence_params)
      redirect_to project_structure_path(@project), notice: "Secuencia actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sequence.destroy
    redirect_to project_structure_path(@project), notice: "Secuencia eliminada exitosamente"
  end

  def move
    new_position = params[:position].to_i
    @sequence.insert_at(new_position + 1)
    head :ok
  rescue => e
    Rails.logger.error "Error moving sequence: #{e.message}"
    head :unprocessable_entity
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
