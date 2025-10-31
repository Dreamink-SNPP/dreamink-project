# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_31_223407) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "acts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position"
    t.bigint "project_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["project_id", "position"], name: "index_acts_on_project_and_position", unique: true
    t.index ["project_id"], name: "index_acts_on_project_id"
  end

  create_table "character_external_traits", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.text "detailed_appearance"
    t.string "economic_situation"
    t.text "education"
    t.text "family_structure"
    t.text "general_appearance"
    t.text "important_possessions"
    t.string "legal_situation"
    t.text "medical_history"
    t.string "pets"
    t.string "profession"
    t.string "residence_type"
    t.datetime "updated_at", null: false
    t.string "usual_location"
    t.index ["character_id"], name: "index_character_external_traits_on_character_id"
  end

  create_table "character_internal_traits", force: :cascade do |t|
    t.text "artistic_inclinations"
    t.string "authority_relationship"
    t.text "beliefs"
    t.bigint "character_id", null: false
    t.string "charitable_activities"
    t.text "conversation_focus"
    t.datetime "created_at", null: false
    t.text "ethics"
    t.string "food_preferences"
    t.text "friendship_relations"
    t.text "habits"
    t.text "heroes_models"
    t.text "hobbies"
    t.text "identity"
    t.text "main_motivation"
    t.text "mental_programs"
    t.text "peculiarities"
    t.text "political_ideas"
    t.string "religion"
    t.string "self_awareness_level"
    t.string "sexuality"
    t.text "skills"
    t.text "spirituality"
    t.string "temporal_location"
    t.string "time_management"
    t.datetime "updated_at", null: false
    t.text "values_priorities"
    t.text "vices"
    t.index ["character_id"], name: "index_character_internal_traits_on_character_id"
  end

  create_table "characters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_characters_on_project_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "project_id", null: false
    t.text "tags"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_ideas_on_project_id"
  end

  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location_type"
    t.string "name"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_locations_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.text "characters_summary"
    t.datetime "created_at", null: false
    t.string "genre"
    t.text "idea"
    t.string "logline"
    t.text "long_synopsis"
    t.text "short_synopsis"
    t.text "storyline"
    t.text "themes"
    t.string "title"
    t.text "tone"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.text "world"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "scene_locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.bigint "scene_id", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_scene_locations_on_location_id"
    t.index ["scene_id"], name: "index_scene_locations_on_scene_id"
  end

  create_table "scenes", force: :cascade do |t|
    t.bigint "act_id"
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position"
    t.bigint "project_id"
    t.bigint "sequence_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["act_id"], name: "index_scenes_on_act_id"
    t.index ["project_id"], name: "index_scenes_on_project_id"
    t.index ["sequence_id", "position"], name: "index_scenes_on_sequence_and_position", unique: true
    t.index ["sequence_id"], name: "index_scenes_on_sequence_id"
  end

  create_table "sequences", force: :cascade do |t|
    t.bigint "act_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position"
    t.bigint "project_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["act_id", "position"], name: "index_sequences_on_act_and_position", unique: true
    t.index ["act_id"], name: "index_sequences_on_act_id"
    t.index ["project_id"], name: "index_sequences_on_project_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "acts", "projects"
  add_foreign_key "character_external_traits", "characters"
  add_foreign_key "character_internal_traits", "characters"
  add_foreign_key "characters", "projects"
  add_foreign_key "ideas", "projects"
  add_foreign_key "locations", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "scene_locations", "locations"
  add_foreign_key "scene_locations", "scenes"
  add_foreign_key "scenes", "acts"
  add_foreign_key "scenes", "projects"
  add_foreign_key "scenes", "sequences"
  add_foreign_key "sequences", "acts"
  add_foreign_key "sequences", "projects"
  add_foreign_key "sessions", "users"
end
