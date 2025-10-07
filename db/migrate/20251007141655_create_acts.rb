class CreateActs < ActiveRecord::Migration[8.0]
  def change
    create_table :acts do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
