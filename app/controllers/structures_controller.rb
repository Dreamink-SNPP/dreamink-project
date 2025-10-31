class StructuresController < ApplicationController
  include ProjectAuthorization

  def show
    @acts = @project.acts.includes(sequences: :scenes).ordered
  end

  def reorder
    type = params[:type]
    ids = params[:ids]

    # Validaciones
    if type.blank? || ids.blank? || !ids.is_a?(Array)
      return render json: { error: "Invalid parameters" }, status: :bad_request
    end

    unless %w[act sequence scene].include?(type)
      return render json: { error: "Invalid type" }, status: :bad_request
    end

    begin
      case type
      when "act"
        reorder_acts(ids)
      when "sequence"
        reorder_sequences(ids)
      when "scene"
        reorder_scenes(ids)
      end

      render json: { success: true }, status: :ok
    rescue StandardError => e
      Rails.logger.error "Reorder error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def reorder_acts(ids)
    # Convertir strings a integers
    ids = ids.map(&:to_i)

    # Obtener todos los acts de una vez
    acts = @project.acts.where(id: ids).index_by(&:id)

    ActiveRecord::Base.transaction do
      # Paso 1: Posiciones temporales negativas (evita conflictos de unique constraint)
      ids.each_with_index do |act_id, index|
        act = acts[act_id]
        next unless act
        act.update_columns(position: -(index + 1000))
      end

      # Paso 2: Posiciones finales
      ids.each_with_index do |act_id, index|
        act = acts[act_id]
        next unless act
        act.update_columns(position: index + 1)
      end
    end
  end

  def reorder_sequences(ids)
    ids = ids.map(&:to_i)

    # Obtener todas las secuencias de una vez
    sequences = @project.sequences.where(id: ids).index_by(&:id)

    ActiveRecord::Base.transaction do
      # Paso 1: Posiciones temporales negativas
      ids.each_with_index do |sequence_id, index|
        sequence = sequences[sequence_id]
        next unless sequence
        sequence.update_columns(position: -(index + 1000)) # Usar números muy negativos
      end

      # Paso 2: Posiciones finales
      ids.each_with_index do |sequence_id, index|
        sequence = sequences[sequence_id]
        next unless sequence
        sequence.update_columns(position: index + 1)
      end
    end
  end

  def reorder_scenes(ids)
    # Convertir strings a integers
    ids = ids.map(&:to_i)

    # Obtener todas las scenes de una vez
    scenes = @project.scenes.where(id: ids).index_by(&:id)

    ActiveRecord::Base.transaction do
      # Paso 1: Posiciones temporales negativas (evita conflictos de unique constraint)
      ids.each_with_index do |scene_id, index|
        scene = scenes[scene_id]
        next unless scene
        scene.update_columns(position: -(index + 1000))
      end

      # Paso 2: Posiciones finales
      ids.each_with_index do |scene_id, index|
        scene = scenes[scene_id]
        next unless scene
        scene.update_columns(position: index + 1)
      end
    end
  end
end
