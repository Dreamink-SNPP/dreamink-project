class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :location_type

      t.timestamps
    end
  end
end
