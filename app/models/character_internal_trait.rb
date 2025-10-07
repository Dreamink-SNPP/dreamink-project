class CharacterInternalTrait < ApplicationRecord
  belongs_to :character

  validates :skills, length: { maximum: 500 }, allow_blank: true
  validates :religion, length: { maximum: 200 }, allow_blank: true
  validates :spirituality, length: { maximum: 500 }, allow_blank: true
  validates :identity, length: { maximum: 500 }, allow_blank: true
  validates :mental_programs, length: { maximum: 500 }, allow_blank: true
  validates :ethics, length: { maximum: 500 }, allow_blank: true
  validates :sexuality, length: { maximum: 200 }, allow_blank: true
  validates :main_motivation, length: { maximum: 500 }, allow_blank: true
  validates :conversation_focus, length: { maximum: 500 }, allow_blank: true
  validates :self_awareness_level, length: { maximum: 300 }, allow_blank: true
  validates :time_management, length: { maximum: 300 }, allow_blank: true
  validates :artistic_inclinations, length: { maximum: 500 }, allow_blank: true
  validates :heroes_models, length: { maximum: 500 }, allow_blank: true
  validates :political_ideas, length: { maximum: 500 }, allow_blank: true
  validates :authority_relationship, length: { maximum: 300 }, allow_blank: true
  validates :vices, length: { maximum: 500 }, allow_blank: true
  validates :temporal_location, length: { maximum: 200 }, allow_blank: true
  validates :food_preferences, length: { maximum: 300 }, allow_blank: true
  validates :habits, length: { maximum: 500 }, allow_blank: true
  validates :peculiarities, length: { maximum: 500 }, allow_blank: true
  validates :hobbies, length: { maximum: 500 }, allow_blank: true
  validates :charitable_activities, length: { maximum: 300 }, allow_blank: true
end
