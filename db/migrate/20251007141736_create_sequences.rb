class CreateSequences < ActiveRecord::Migration[8.0]
  def change
    create_table :sequences do |t|
      t.references :act, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
