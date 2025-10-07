class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :genre
      t.text :idea
      t.string :logline
      t.text :storyline
      t.text :short_synopsis
      t.text :long_synopsis
      t.text :world
      t.text :characters_summary
      t.text :story_engine
      t.text :themes
      t.text :tone

      t.timestamps
    end
  end
end
