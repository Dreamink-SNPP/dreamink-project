class RemoveStoryEngineFromProjects < ActiveRecord::Migration[8.1]
  def change
    remove_column :projects, :story_engine, :text
  end
end
