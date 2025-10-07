class Idea < ApplicationRecord
  belongs_to :project

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :search, ->(query) { where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }
  scope :tagged_with, ->(tag) { where("tags ILIKE ?", "%#{tag}%") }

end
