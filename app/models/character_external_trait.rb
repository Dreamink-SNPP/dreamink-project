class CharacterExternalTrait < ApplicationRecord
  belongs_to :character

  validates :medical_history, length: { maximum: 500 }, allow_blank: true
  validates :education, length: { maximum: 500 }, allow_blank: true
  validates :profession, length: { maximum: 300 }, allow_blank: true
  validates :legal_situation, length: { maximum: 300 }, allow_blank: true
  validates :economic_situation, length: { maximum: 300 }, allow_blank: true
  validates :important_possessions, length: { maximum: 500 }, allow_blank: true
  validates :residence_type, length: { maximum: 300 }, allow_blank: true
  validates :usual_location, length: { maximum: 300 }, allow_blank: true
  validates :pets, length: { maximum: 300 }, allow_blank: true
end
