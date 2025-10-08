include UserScoped

class Act < ApplicationRecord
  belongs_to :project
  has_many :sequences, -> { order(position: :asc) }, dependent: :destroy
  has_many :scenes, through: :sequences

  acts_as_list scope: :project

  validates :title, presence: true, length: { maximum: 100 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :position, uniqueness: { scope: :project_id }

  # Callbacks for auto-positioning:
  before_validation :set_position, on: :create

  scope :ordered, -> { order(position: :asc) }

  private

  def set_position
    self.position ||= project.acts.maximum(:position).to_i + 1
  end
end
