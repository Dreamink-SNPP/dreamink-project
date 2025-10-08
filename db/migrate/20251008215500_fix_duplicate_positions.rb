# db/migrate/XXXXXX_fix_duplicate_positions.rb
class FixDuplicatePositions < ActiveRecord::Migration[8.0]
  def up
    # Arreglar actos
    Project.find_each do |project|
      project.acts.order(:created_at).each_with_index do |act, index|
        act.update_column(:position, index + 1)
      end
    end

    # Arreglar secuencias
    Act.find_each do |act|
      act.sequences.order(:created_at).each_with_index do |sequence, index|
        sequence.update_column(:position, index + 1)
      end
    end

    # Arreglar escenas
    Sequence.find_each do |sequence|
      sequence.scenes.order(:created_at).each_with_index do |scene, index|
        scene.update_column(:position, index + 1)
      end
    end
  end

  def down
    # No es necesario revertir
  end
end
