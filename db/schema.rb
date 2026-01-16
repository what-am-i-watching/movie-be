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

ActiveRecord::Schema[8.1].define(version: 2026_01_16_003009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "friendships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "friend_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "poster_url"
    t.integer "release_year"
    t.string "title"
    t.integer "tmdb_id"
    t.datetime "updated_at", null: false
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.integer "key_hash", null: false
    t.binary "value", null: false
    t.index ["key", "created_at"], name: "index_solid_cache_entries_on_key_and_created_at"
    t.index ["key"], name: "index_solid_cache_entries_on_key", unique: true
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "user_movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "movie_id", null: false
    t.text "notes"
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "watched", default: false
    t.index ["movie_id"], name: "index_user_movies_on_movie_id"
    t.index ["user_id"], name: "index_user_movies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "friendships", "users"
  add_foreign_key "user_movies", "movies"
  add_foreign_key "user_movies", "users"
end
