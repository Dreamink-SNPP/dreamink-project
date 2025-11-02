class AddTimeOfDayToScenes < ActiveRecord::Migration[8.1]
  def change
    add_column :scenes, :time_of_day, :string, limit: 20, comment: "Time of day for scene heading (e.g., DAY, NIGHT, MORNING)"
  end
end
