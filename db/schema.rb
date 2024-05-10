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

ActiveRecord::Schema.define(version: 2024_01_20_025601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "actions", force: :cascade do |t|
    t.integer "action_type"
    t.bigint "guest_id"
    t.string "entity_type"
    t.bigint "entity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.index ["entity_type", "entity_id"], name: "index_actions_on_entity"
    t.index ["guest_id"], name: "index_actions_on_guest_id"
  end

  create_table "ad_banners", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "ad_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "article_type"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "attachable_type"
    t.bigint "attachable_id"
    t.string "attachment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.text "description"
    t.bigint "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.string "original_title"
    t.boolean "show", default: true
    t.index ["category_id"], name: "index_categories_on_category_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "coupon_id"
    t.string "name"
    t.string "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "resource_id"
    t.integer "status"
    t.string "code"
    t.boolean "exclusive"
    t.integer "coupon_type"
    t.float "percentage_off"
    t.float "dollar_off"
    t.jsonb "response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_id"], name: "index_coupons_on_resource_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "fp", id: false, force: :cascade do |t|
    t.bigint "id"
    t.string "name"
    t.string "title"
    t.text "description"
    t.integer "price"
    t.integer "old_price"
    t.string "discount"
    t.string "rating"
    t.string "brand_name"
    t.string "link"
    t.string "click_link"
    t.jsonb "specifications"
    t.string "seller"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.bigint "category_id"
    t.string "product_type"
    t.datetime "refreshed_at"
    t.string "country_fltr"
    t.string "strength_fltr"
    t.string "wrapper_fltr"
    t.string "shape_fltr"
    t.string "length_fltr"
    t.bigint "resource_id"
    t.integer "int_rating"
    t.bigint "length_id"
    t.bigint "brand_id"
    t.bigint "product_type_id"
    t.bigint "country_id"
    t.bigint "strength_id"
    t.bigint "wrapper_id"
    t.bigint "shape_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "ip"
    t.string "location"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_guests_on_user_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "meta_tags", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "page_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pages", force: :cascade do |t|
    t.integer "page_type"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "description"
    t.integer "price", default: 0
    t.integer "old_price", default: 0
    t.string "discount"
    t.string "rating"
    t.string "brand_name"
    t.string "link"
    t.string "click_link"
    t.jsonb "specifications"
    t.string "seller"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "category_id"
    t.string "product_type"
    t.datetime "refreshed_at"
    t.string "country_fltr"
    t.string "strength_fltr"
    t.string "wrapper_fltr"
    t.string "shape_fltr"
    t.string "length_fltr"
    t.bigint "resource_id"
    t.integer "int_rating"
    t.bigint "length_id"
    t.bigint "brand_id"
    t.bigint "product_type_id"
    t.bigint "country_id"
    t.bigint "strength_id"
    t.bigint "wrapper_id"
    t.bigint "shape_id"
    t.integer "status", default: 0
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["brand_name"], name: "index_products_on_brand_name"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["country_fltr"], name: "index_products_on_country_fltr"
    t.index ["country_id"], name: "index_products_on_country_id"
    t.index ["length_fltr"], name: "index_products_on_length_fltr"
    t.index ["length_id"], name: "index_products_on_length_id"
    t.index ["link"], name: "index_products_on_link", unique: true
    t.index ["product_type"], name: "index_products_on_product_type"
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
    t.index ["resource_id"], name: "index_products_on_resource_id"
    t.index ["seller"], name: "index_products_on_seller"
    t.index ["shape_fltr"], name: "index_products_on_shape_fltr"
    t.index ["shape_id"], name: "index_products_on_shape_id"
    t.index ["strength_fltr"], name: "index_products_on_strength_fltr"
    t.index ["strength_id"], name: "index_products_on_strength_id"
    t.index ["title"], name: "index_products_on_title", opclass: :gist_trgm_ops, using: :gist
    t.index ["wrapper_fltr"], name: "index_products_on_wrapper_fltr"
    t.index ["wrapper_id"], name: "index_products_on_wrapper_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_purchases_on_product_id"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "host"
    t.boolean "show", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "rating"
    t.bigint "user_id"
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reviewer_name"
    t.datetime "review_date"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "system_settings", force: :cascade do |t|
    t.string "sitemap"
    t.string "sitemap_arx"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password"
    t.string "salt"
    t.string "email"
    t.string "phone_number"
    t.string "token"
    t.string "full_name"
    t.string "state"
    t.string "city"
    t.string "address"
    t.string "social_id"
    t.integer "social_type"
    t.boolean "confirmed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "newsletter", default: true
    t.string "image"
    t.boolean "self_update", default: false
  end

  create_table "views", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "entity_type"
    t.bigint "entity_id"
    t.bigint "guest_id"
    t.index ["entity_type", "entity_id"], name: "index_views_on_entity"
    t.index ["guest_id"], name: "index_views_on_guest_id"
    t.index ["product_id"], name: "index_views_on_product_id"
    t.index ["user_id"], name: "index_views_on_user_id"
  end

end
