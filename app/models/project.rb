class Project < ApplicationRecord
  belongs_to :user
  # Validations:
  has_many :acts, -> { order(position: :asc) }, dependent: :destroy
  has_many :sequences, through: :acts
  has_many :scenes, through: :sequences
  has_many :characters, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :ideas, -> { order(created_at: :desc) }, dependent: :destroy
  # Privacy scope:
  scope :for_user, ->(user) { where(user: user) }
end
