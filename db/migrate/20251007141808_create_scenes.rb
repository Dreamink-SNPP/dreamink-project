class CreateScenes < ActiveRecord::Migration[8.0]
  def change
    create_table :scenes do |t|
      t.references :sequence, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :color
      t.integer :position

      t.timestamps
    end
  end
end
