class CreateCharacterExternalTraits < ActiveRecord::Migration[8.0]
  def change
    create_table :character_external_traits do |t|
      t.references :character, null: false, foreign_key: true
      t.text :general_appearance
      t.text :detailed_appearance
      t.text :medical_history
      t.text :family_structure
      t.text :education
      t.string :profession
      t.string :legal_situation
      t.string :economic_situation
      t.text :important_possessions
      t.string :residence_type
      t.string :usual_location
      t.string :pets

      t.timestamps
    end
  end
end
