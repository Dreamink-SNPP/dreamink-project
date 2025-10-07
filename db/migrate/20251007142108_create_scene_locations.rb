class CreateSceneLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :scene_locations do |t|
      t.references :scene, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
