include UserScoped

class Sequence < ApplicationRecord
  belongs_to :act
  belongs_to :project

  has_many :scenes, -> { order(position: :asc) }, dependent: :destroy

  acts_as_list scope: :act

  # Validations:
  validates :title, presence: true, length: { maximum: 100 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks:
  before_validation :set_position, on: :create
  before_validation :sync_project_reference

  # Scopes:
  scope :ordered, -> { order(position: :asc) }

  private

  def set_position
    self.position ||= act.sequences.maximum(:position).to_i + 1
  end

  def sync_project_reference
    self.project_id = act.project_id if act
  end
end
