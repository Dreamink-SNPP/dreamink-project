include UserScoped

class Location < ApplicationRecord
  belongs_to :project

  has_many :scene_locations, dependent: :destroy
  has_many :scenes, through: :scene_locations

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :project_id }
  validates :location_type, inclusion: { in: %w[interior exterior], message: "%{value} no es un tipo válido" }, allow_blank: true


  scope :interiors, -> { where(location_type: "interior") }
  scope :exteriors, -> { where(location_type: "exterior") }

  def interior?
    location_type == "interior"
  end

  def exterior?
    location_type == "exterior"
  end
end
