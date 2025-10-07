class CreateCharacterInternalTraits < ActiveRecord::Migration[8.0]
  def change
    create_table :character_internal_traits do |t|
      t.references :character, null: false, foreign_key: true
      t.text :skills
      t.string :religion
      t.text :spirituality
      t.text :identity
      t.text :beliefs
      t.text :mental_programs
      t.text :ethics
      t.string :sexuality
      t.text :main_motivation
      t.text :friendship_relations
      t.text :conversation_focus
      t.string :self_awareness_level
      t.text :values_priorities
      t.string :time_management
      t.text :artistic_inclinations
      t.text :heroes_models
      t.text :political_ideas
      t.string :authority_relationship
      t.text :vices
      t.string :temporal_location
      t.string :food_preferences
      t.text :habits
      t.text :peculiarities
      t.text :hobbies
      t.string :charitable_activities

      t.timestamps
    end
  end
end
