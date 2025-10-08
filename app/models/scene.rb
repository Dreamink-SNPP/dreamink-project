include UserScoped

class Scene < ApplicationRecord
  belongs_to :sequence

  has_one :act, through: :sequence
  has_one :project, through: :act
  has_many :scene_locations, dependent: :destroy
  has_many :locations, through: :scene_locations

  acts_as_list scope: :sequence

  # Validations:
  validates :title, presence: true, length: { maximum: 200 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :position, uniqueness: { scope: :sequence_id }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i, allow_blank: true }

  # Callbacks:
  before_validation :set_position, on: :create
  before_validation :set_default_color, on: :create

  # Scopes:
  scope :ordered, -> { order(position: :asc) }
  scope :by_color, ->(color) { where(color: color) }

  private

  def set_position
    self.position ||= sequence.scenes.maximum(:position).to_i + 1
  end

  def set_default_color
    self.color ||= '#FFFFFF'
  end
end
