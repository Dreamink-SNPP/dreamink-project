class StructuresController < ApplicationController
  include ProjectAuthorization

  def show
    @acts = @project.acts.includes(sequences: :scenes).ordered
  end

  def reorder
    case params[:type]
    when 'act'
      reorder_acts
    when 'sequence'
      reorder_sequences
    when 'scene'
      reorder_scenes
    else
      head :bad_request
    end
  end

  private

  def reorder_acts
    params[:acts].each_with_index do |act_id, index|
      Act.find(act_id).update(position: index)
    end
    head :ok
  end

  def reorder_sequences
    params[:sequences].each_with_index do |sequence_id, index|
      Sequence.find(sequence_id).update(position: index)
    end
    head :ok
  end

  def reorder_scenes
    params[:scenes].each_with_index do |scene_id, index|
      Scene.find(scene_id).update(position: index)
    end
    head :ok
  end
end
