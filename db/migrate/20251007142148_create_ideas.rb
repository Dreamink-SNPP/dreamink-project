class CreateIdeas < ActiveRecord::Migration[8.0]
  def change
    create_table :ideas do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.text :tags

      t.timestamps
    end
  end
end
