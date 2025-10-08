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
    ids = params[:ids]
    return head :bad_request if ids.blank?

    # Actualizar posiciones en una transacción
    ActiveRecord::Base.transaction do
      ids.each_with_index do |act_id, index|
        act = @project.acts.find(act_id)
        # acts_as_list usa posiciones 1-based
        act.update_column(:position, index + 1)
      end
    end

    head :ok
  rescue => e
    Rails.logger.error "Error reordering acts: #{e.message}"
    head :unprocessable_entity
  end

  def reorder_sequences
    ids = params[:ids]
    return head :bad_request if ids.blank?

    ActiveRecord::Base.transaction do
      ids.each_with_index do |sequence_id, index|
        sequence = @project.sequences.find(sequence_id)
        sequence.update_column(:position, index + 1)
      end
    end

    head :ok
  rescue => e
    Rails.logger.error "Error reordering sequences: #{e.message}"
    head :unprocessable_entity
  end

  def reorder_scenes
    ids = params[:ids]
    return head :bad_request if ids.blank?

    ActiveRecord::Base.transaction do
      ids.each_with_index do |scene_id, index|
        scene = @project.scenes.find(scene_id)
        scene.update_column(:position, index + 1)
      end
    end

    head :ok
  rescue => e
    Rails.logger.error "Error reordering scenes: #{e.message}"
    head :unprocessable_entity
  end
end
