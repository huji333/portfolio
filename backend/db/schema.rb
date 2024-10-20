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

ActiveRecord::Schema[7.2].define(version: 2024_10_19_063915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cameras", force: :cascade do |t|
    t.string "name", null: false
    t.string "manufacturer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "image_categories", force: :cascade do |t|
    t.bigint "image_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_image_categories_on_category_id"
    t.index ["image_id", "category_id"], name: "index_image_categories_on_image_id_and_category_id", unique: true
    t.index ["image_id"], name: "index_image_categories_on_image_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "title", null: false
    t.string "caption", null: false
    t.datetime "taken_at", null: false
    t.bigint "camera_id", null: false
    t.bigint "lens_id", null: false
    t.integer "display_order", null: false
    t.boolean "is_published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camera_id"], name: "index_images_on_camera_id"
    t.index ["display_order"], name: "index_images_on_display_order"
    t.index ["is_published"], name: "index_images_on_is_published"
    t.index ["lens_id"], name: "index_images_on_lens_id"
    t.index ["taken_at"], name: "index_images_on_taken_at"
  end

  create_table "lenses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "title", null: false
    t.string "link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publishments", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "published_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_publishments_on_article_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "image_categories", "categories"
  add_foreign_key "image_categories", "images"
  add_foreign_key "images", "cameras"
  add_foreign_key "images", "lenses"
  add_foreign_key "publishments", "articles"
end
