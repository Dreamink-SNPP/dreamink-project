class SequencesController < ApplicationController include ProjectAuthorization
  before_action :set_sequence, only: [:edit, :update, :destroy, :move]
  before_action :set_act, only: [:new, :create]

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
    @sequence.insert_at(new_position)
    head :ok
  end
end
