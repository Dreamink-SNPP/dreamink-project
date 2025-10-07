class SceneLocation < ApplicationRecord
  belongs_to :scene
  belongs_to :location

  validates :location_id, uniqueness: { scope: :scene_id }
end
