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

ActiveRecord::Schema[8.0].define(version: 2025_10_07_142148) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "acts", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title"
    t.text "description"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_acts_on_project_id"
  end

  create_table "character_external_traits", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.text "general_appearance"
    t.text "detailed_appearance"
    t.text "medical_history"
    t.text "family_structure"
    t.text "education"
    t.string "profession"
    t.string "legal_situation"
    t.string "economic_situation"
    t.text "important_possessions"
    t.string "residence_type"
    t.string "usual_location"
    t.string "pets"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_external_traits_on_character_id"
  end

  create_table "character_internal_traits", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.text "skills"
    t.string "religion"
    t.text "spirituality"
    t.text "identity"
    t.text "beliefs"
    t.text "mental_programs"
    t.text "ethics"
    t.string "sexuality"
    t.text "main_motivation"
    t.text "friendship_relations"
    t.text "conversation_focus"
    t.string "self_awareness_level"
    t.text "values_priorities"
    t.string "time_management"
    t.text "artistic_inclinations"
    t.text "heroes_models"
    t.text "political_ideas"
    t.string "authority_relationship"
    t.text "vices"
    t.string "temporal_location"
    t.string "food_preferences"
    t.text "habits"
    t.text "peculiarities"
    t.text "hobbies"
    t.string "charitable_activities"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_internal_traits_on_character_id"
  end

  create_table "characters", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_characters_on_project_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title"
    t.text "description"
    t.text "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_ideas_on_project_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.text "description"
    t.string "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_locations_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "genre"
    t.text "idea"
    t.string "logline"
    t.text "storyline"
    t.text "short_synopsis"
    t.text "long_synopsis"
    t.text "world"
    t.text "characters_summary"
    t.text "story_engine"
    t.text "themes"
    t.text "tone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "scene_locations", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_scene_locations_on_location_id"
    t.index ["scene_id"], name: "index_scene_locations_on_scene_id"
  end

  create_table "scenes", force: :cascade do |t|
    t.bigint "sequence_id", null: false
    t.string "title"
    t.text "description"
    t.string "color"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sequence_id"], name: "index_scenes_on_sequence_id"
  end

  create_table "sequences", force: :cascade do |t|
    t.bigint "act_id", null: false
    t.string "title"
    t.text "description"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id"], name: "index_sequences_on_act_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
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
  add_foreign_key "scenes", "sequences"
  add_foreign_key "sequences", "acts"
  add_foreign_key "sessions", "users"
end
