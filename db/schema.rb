ActiveRecord::Schema.define(version: 2024_05_07) do
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "occupation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "biography", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", default: ""
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at", null: true
    t.boolean "archived", default: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "post_tags", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "tag_id"], name: "index_post_tags_on_post_id_and_tag_id", unique: true
    t.index ["post_id"], name: "index_post_tags_on_post_id"
    t.index ["tag_id"], name: "index_post_tags_on_tag_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "controller", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description", default: ""
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "location", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
    t.index ["start_at"], name: "index_events_on_start_at"
  end

  create_table "purchase_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.integer "price", null: false
    t.datetime "purchase_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "products" do |t|
    t.string "name", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name", unique: true
    t.index ["category"], name: "index_products_on_category"
  end

  create_table "product_sales_infos" do |t|
  t.bigint "product_id", null: false
  t.integer "price", null: false
  t.datetime "effective_from", null: false
  t.boolean "discontinued", default: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["product_id"], name: "index_product_sales_infos_on_product_id"
end

  create_table "orders" do |t|
    t.bigint "user_id", null: false
    t.datetime "order_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "order_cancels" do |t|
    t.bigint "order_id", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_cancels_on_order_id"
  end

  create_table "order_items" do |t|
    t.bigint "order_id", null: false
    t.bigint "product_sales_info_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "shipments" do |t|
    t.bigint "order_id", null: false
    t.string "tracking_number", null: false
    t.integer "status", null: false, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shipments_on_order_id"
  end

  create_table "inventories" do |t|
    t.bigint "product_id", null: false
    t.integer "quantity", null: false, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_inventories_on_product_id", unique: true
  end

  create_table "unnormalized_purchase_histories", force: :cascade do |t|
    t.string "user_name", null: false
    t.string "user_email", null: false
    t.string "product_name", null: false
    t.integer "product_price", null: false
    t.integer "quantity", null: false
    t.string "category_name", null: false
    t.datetime "purchase_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_email"], name: "index_unnormalized_purchase_histories_on_user_email"
  end

  add_foreign_key "profiles", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "post_tags", "posts"
  add_foreign_key "post_tags", "tags"
  add_foreign_key "permissions", "users"
  add_foreign_key "events", "users"
  add_foreign_key "product_sales_infos", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_sales_infos"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "inventories", "products"
end
