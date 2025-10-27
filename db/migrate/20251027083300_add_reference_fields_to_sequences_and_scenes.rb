class AddReferenceFieldsToSequencesAndScenes < ActiveRecord::Migration[8.0]
  def change
    # Agregar project_id a sequences (para queries más rápidas)
    add_reference :sequences, :project, foreign_key: true, index: true

    # Agregar project_id y act_id a scenes (para queries más rápidas)
    add_reference :scenes, :project, foreign_key: true, index: true
    add_reference :scenes, :act, foreign_key: true, index: true

    # Poblar los datos existentes
    reversible do |dir|
      dir.up do
        # Actualizar sequences.project_id basándose en act.project_id
        execute <<-SQL
          UPDATE sequences
          SET project_id = acts.project_id
          FROM acts
          WHERE sequences.act_id = acts.id
        SQL

        # Actualizar scenes.project_id y scenes.act_id
        execute <<-SQL
          UPDATE scenes
          SET
            project_id = acts.project_id,
            act_id = sequences.act_id
          FROM sequences
          INNER JOIN acts ON sequences.act_id = acts.id
          WHERE scenes.sequence_id = sequences.id
        SQL
      end
    end
  end
end
