class Act < ApplicationRecord
  belongs_to :project
  has_many :sequences, -> { order(position: :asc) }, dependent: :destroy
  has_many :scenes, through: :sequences

  validates :title, presence: true, length: { maximum: 100 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :position, uniqueness: { scope: :project_id }
end
