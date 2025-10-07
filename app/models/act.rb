class Act < ApplicationRecord
  belongs_to :project
  has_many :sequences, -> { order(position: :asc) }, dependent: :destroy
  has_many :scenes, through: :sequences
end
