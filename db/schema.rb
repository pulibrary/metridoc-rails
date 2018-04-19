# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "DATABASECHANGELOG", primary_key: ["ID", "AUTHOR", "FILENAME"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "ID", limit: 63, null: false
    t.string "AUTHOR", limit: 63, null: false
    t.string "FILENAME", limit: 200, null: false
    t.datetime "DATEEXECUTED", null: false
    t.integer "ORDEREXECUTED", null: false
    t.string "EXECTYPE", limit: 10, null: false
    t.string "MD5SUM", limit: 35
    t.string "DESCRIPTION"
    t.string "COMMENTS"
    t.string "TAG"
    t.string "LIQUIBASE", limit: 20
  end

  create_table "DATABASECHANGELOGLOCK", primary_key: "ID", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "LOCKED", null: false
    t.datetime "LOCKGRANTED"
    t.string "LOCKEDBY"
  end

  create_table "app_category", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.binary "admin_only", limit: 1, null: false
    t.string "icon_name"
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "application_properties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "name", null: false
    t.string "value", null: false
  end

  create_table "bd_bibliography", primary_key: "bibliography_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains resource information", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.string "patron_id", limit: 20, comment: "the unique identifer of the requestor"
    t.string "patron_type", limit: 1, comment: "the role of the requestor"
    t.string "author", limit: 300
    t.string "title", limit: 400
    t.string "publisher", limit: 256
    t.string "publication_place", limit: 256
    t.string "publication_year", limit: 4, comment: "the unique online series identifer"
    t.string "edition", limit: 24
    t.string "lccn", limit: 32
    t.string "isbn", limit: 24
    t.string "isbn_2", limit: 24
    t.datetime "request_date", comment: "date the request was first submitted by the patron into the system"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.string "pickup_location", limit: 64, comment: "location of fulfillment acquisition"
    t.integer "borrower", comment: "requesting library identifier"
    t.integer "lender", comment: "fulfilling library identifier "
    t.string "supplier_code", limit: 20, comment: "the shelving location preceded by a two letter code defining the institution"
    t.string "call_number", limit: 256, comment: "specific location identifier of request fulfillment"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.integer "oclc"
    t.string "oclc_text", limit: 25
    t.bigint "version", default: 0, null: false
    t.string "publication_date"
    t.string "local_item_found", limit: 1
    t.index ["borrower"], name: "idx_bd_bibliography_borrower"
    t.index ["lender"], name: "idx_bd_bibliography_lender"
    t.index ["request_date"], name: "idx_bd_bibliography_request_date"
    t.index ["request_number"], name: "idx_bd_bibliography_request_number"
    t.index ["request_number"], name: "uk_bd_bibliography_request_number", unique: true
    t.index ["supplier_code"], name: "idx_bd_bibliography_supplier_code"
  end

  create_table "bd_call_number", primary_key: "call_number_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains resource location information", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.integer "holdings_seq", comment: "identifier of fullfillment attempt"
    t.string "supplier_code", limit: 20, comment: "the shelving location preceded by a two letter code defining the institution"
    t.string "call_number", limit: 256, comment: "specific location identifier of request fulfillment"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.bigint "version", default: 0, null: false
    t.index ["request_number"], name: "fk_bd_call_number_load_request_number"
    t.index ["request_number"], name: "request_number"
  end

  create_table "bd_exception_code", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains reasons for changes in request status", force: :cascade do |t|
    t.string "exception_code", limit: 3, default: "", null: false, comment: "code identifier"
    t.string "exception_code_desc", limit: 64, comment: "exception description"
    t.bigint "version", default: 0, null: false
    t.index ["exception_code"], name: "exception_code", unique: true
    t.index ["exception_code_desc"], name: "exception_code_desc", unique: true
  end

  create_table "bd_institution", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains institution identification", force: :cascade do |t|
    t.string "catalog_code", limit: 1, default: "", null: false, comment: "institution identifier"
    t.string "institution", limit: 64, null: false
    t.integer "library_id", null: false
    t.bigint "version", default: 0, null: false
    t.index ["id"], name: "id", unique: true
    t.index ["institution"], name: "catalog_code_desc", unique: true
    t.index ["institution"], name: "institution", unique: true
    t.index ["library_id"], name: "catalog_library_id", unique: true
    t.index ["library_id"], name: "library_id", unique: true
  end

  create_table "bd_min_ship_date", primary_key: "request_number", id: :string, limit: 12, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.timestamp "min_ship_date", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "bd_patron_type", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains contains requestor roles", force: :cascade do |t|
    t.string "patron_type", limit: 1, default: "", null: false, comment: "role identifier"
    t.string "patron_type_desc", limit: 50, comment: "role description"
    t.index ["patron_type"], name: "patron_type", unique: true
    t.index ["patron_type_desc"], name: "patron_type_desc", unique: true
  end

  create_table "bd_print_date", primary_key: "print_date_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains dates request was printed", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.datetime "print_date", comment: "date request was printed"
    t.string "note", limit: 256, comment: "request-specific info"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.integer "library_id"
    t.bigint "version", default: 0, null: false
    t.index ["request_number"], name: "fk_bd_print_date_request_number"
  end

  create_table "bd_report_distribution", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email_addr", limit: 32, null: false
    t.integer "institution_id", null: false
    t.bigint "version", default: 0, null: false
    t.string "library_id", null: false
    t.index ["id"], name: "id", unique: true
  end

  create_table "bd_report_distribution_tmp", id: :bigint, default: 0, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email_addr", limit: 32, null: false
    t.integer "institution_id", null: false
    t.bigint "version", default: 0, null: false
    t.string "library_id", null: false
  end

  create_table "bd_ship_date", primary_key: "ship_date_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains dates request was shipped and or received", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.string "ship_date", limit: 24, null: false
    t.string "exception_code", limit: 3, comment: "code identifying reason for change in request status"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.bigint "version", default: 0, null: false
    t.index ["request_number"], name: "idx_bd_ship_date_request_number"
    t.index ["ship_date"], name: "idx_bd_ship_date_ship_date"
  end

  create_table "bib_trans_new", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "create_date"
    t.string "display_call_no", limit: 200
    t.bigint "item_id", null: false
    t.string "item_type_code"
    t.string "location_name", limit: 25
    t.string "normalized_call_no", limit: 200
    t.bigint "perm_location"
    t.bigint "temp_location"
    t.index ["item_id"], name: "item_id", unique: true
    t.index ["normalized_call_no"], name: "idx_bib_trans_new_normcall"
    t.index ["perm_location"], name: "idx_bib_location_permlocation"
    t.index ["temp_location"], name: "idx_bib_location_templocation"
  end

  create_table "circ_location_lookup", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "location_display_name", limit: 100, null: false
    t.bigint "location_id", null: false
    t.index ["location_id"], name: "location_id", unique: true
  end

  create_table "circ_trans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "charge_date"
    t.string "charge_location", limit: 25
    t.bigint "circ_transaction_id"
    t.datetime "discharge_date"
    t.string "discharge_location", limit: 25
    t.bigint "item_id", null: false
    t.string "item_type_code", limit: 10
    t.string "location_name", limit: 25
    t.string "patron_group_name"
    t.index ["item_id"], name: "idx_circ_trans_itemid"
  end

  create_table "controller_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "app_description", null: false
    t.string "app_name", null: false
    t.bigint "category_id", null: false
    t.string "controller_path", null: false
    t.binary "home_page", limit: 1, null: false
    t.string "validity", null: false
    t.index ["app_name"], name: "app_name", unique: true
    t.index ["category_id"], name: "FKE825266DC19009D5"
    t.index ["controller_path"], name: "controller_path", unique: true
  end

  create_table "crypt_key", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "encrypt_key", null: false
  end

  create_table "ered_center", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "center_id", null: false
    t.string "org_code", null: false
    t.string "org_name", null: false
    t.index ["center_id"], name: "idx_ered_center_center_id"
    t.index ["org_code"], name: "org_code", unique: true
  end

  create_table "ered_person", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "affiliation_active_code", limit: 1, null: false
    t.string "affiliation_code", limit: 4, null: false
    t.datetime "date_created", null: false
    t.string "dept", limit: 72
    t.binary "encrypted_pennkey", limit: 1, null: false
    t.string "org_active_code", limit: 3
    t.string "org_code", limit: 5
    t.string "pennkey"
    t.string "pennkey_active_code", limit: 1, null: false
    t.string "rank", limit: 32
    t.integer "top_rank", default: 0, null: false
    t.bigint "rank_id", null: false
    t.binary "top_rank_processed", limit: 1, null: false
    t.string "org_name"
    t.index ["pennkey"], name: "pennkey_idx"
    t.index ["rank_id"], name: "FK720CF0E57A858686"
    t.index ["top_rank"], name: "top_rank_idx"
  end

  create_table "ered_person_loading", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "affiliation_active_code", limit: 1, null: false
    t.string "affiliation_code", limit: 4, null: false
    t.datetime "date_created", null: false
    t.string "dept", limit: 72
    t.binary "encrypted_pennkey", limit: 1, null: false
    t.string "org_active_code", limit: 3
    t.string "org_code", limit: 5
    t.string "pennkey"
    t.string "pennkey_active_code", limit: 1, null: false
    t.string "rank", limit: 32
    t.integer "top_rank", default: 0, null: false
    t.bigint "rank_id", null: false
    t.binary "top_rank_processed", limit: 1, null: false
    t.string "org_name"
    t.index ["pennkey"], name: "pennkey_idx"
    t.index ["rank_id"], name: "FK37D0E87A858686"
    t.index ["top_rank"], name: "top_rank_idx"
  end

  create_table "ered_rank", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "rank_code", limit: 32, null: false
    t.string "rank_desc", limit: 64, null: false
    t.integer "weight", default: 4, null: false
    t.index ["rank_code"], name: "idx_ered_rank_rank_code"
    t.index ["weight"], name: "idx_ered_rank_rank_weight"
  end

  create_table "ez_doi", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "ez_doi_journal_id", null: false
    t.string "ezproxy_id", limit: 50, null: false
    t.string "file_name", null: false
    t.integer "line_number", null: false
    t.datetime "proxy_date", null: false
    t.integer "proxy_day", null: false
    t.integer "proxy_month", null: false
    t.integer "proxy_year", null: false
    t.string "url_host", null: false
    t.bigint "version", null: false
    t.index ["ez_doi_journal_id"], name: "FKB33D5EB4C6BC072B"
    t.index ["ezproxy_id"], name: "idx_ezproxy_id"
    t.index ["file_name"], name: "idx_file_name"
    t.index ["url_host"], name: "idx_url_host"
  end

  create_table "ez_doi_author", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
  end

  create_table "ez_doi_isbn", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "isbn", limit: 64, null: false
    t.string "isbn_type", limit: 20
  end

  create_table "ez_doi_issn", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "issn", limit: 24, null: false
    t.string "issn_type", limit: 20
  end

  create_table "ez_doi_journal", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "article_title"
    t.string "doi", null: false
    t.string "electronic_isbn"
    t.string "electronic_issn"
    t.integer "electronic_year"
    t.string "first_page"
    t.string "given_name"
    t.string "issue"
    t.string "journal_title"
    t.string "last_page"
    t.integer "null_year"
    t.integer "online_year"
    t.integer "other_year"
    t.string "print_isbn"
    t.string "print_issn"
    t.integer "print_year"
    t.binary "processed_doi", limit: 1, null: false
    t.binary "resolvable_doi", limit: 1, null: false
    t.string "sur_name"
    t.string "volume"
    t.index ["doi"], name: "doi", unique: true
  end

  create_table "ez_file_meta_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "file_name", null: false
    t.string "sha256", limit: 64, null: false
    t.datetime "process_started"
    t.binary "processing", limit: 1
    t.index ["file_name"], name: "idx_ez_hosts_file_name"
  end

  create_table "ez_hosts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "version"
    t.string "ezproxy_id", limit: 50, null: false
    t.string "file_name", null: false
    t.integer "line_number", null: false
    t.datetime "proxy_date", null: false
    t.integer "proxy_day", null: false
    t.integer "proxy_month", null: false
    t.integer "proxy_year", null: false
    t.string "url_host", null: false
    t.string "city"
    t.string "country"
    t.string "department"
    t.string "ip_address"
    t.string "organization"
    t.string "patron_id"
    t.string "rank"
    t.string "state"
    t.index ["ezproxy_id", "url_host"], name: "ezproxy_id", unique: true
    t.index ["ezproxy_id", "url_host"], name: "idx_ezproxy_id_url_host"
    t.index ["ezproxy_id"], name: "idx_ezproxy_id"
    t.index ["file_name"], name: "idx_file_name"
    t.index ["patron_id"], name: "patronId_idx"
    t.index ["url_host"], name: "idx_url_host"
  end

  create_table "ez_parser_properties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "directory"
    t.string "encoding", null: false
    t.text "ezproxy_parser_template", limit: 4294967295, null: false
    t.binary "job_activated", limit: 1, null: false
    t.text "sample_log", limit: 4294967295
    t.text "sample_parser", limit: 4294967295
    t.binary "anonymize_patron_info", limit: 1, null: false
    t.string "cross_ref_encryption_key", null: false
    t.string "cross_ref_password", null: false
    t.string "cross_ref_user_name", null: false
    t.binary "encrypt_patron_info", limit: 1, null: false
    t.string "file_filter"
    t.binary "store_patron_id", limit: 1, null: false
  end

  create_table "ez_properties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.datetime "date_created", null: false
    t.string "property_name", null: false
    t.text "property_value", limit: 4294967295, null: false
  end

  create_table "ez_proxy_session_id", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "ez_proxy_session_id_data_id", null: false
    t.string "ezproxy_id", limit: 50, null: false
    t.string "file_name", limit: 150, null: false
    t.integer "line_number", null: false
    t.datetime "proxy_date", null: false
    t.integer "proxy_day", null: false
    t.integer "proxy_month", null: false
    t.integer "proxy_year", null: false
    t.string "url_host", limit: 150, null: false
    t.index ["ez_proxy_session_id_data_id"], name: "FK77C6F01FBA102D01"
    t.index ["ezproxy_id"], name: "idx_ezproxy_id"
    t.index ["file_name"], name: "idx_file_name"
    t.index ["url_host"], name: "idx_url_host"
  end

  create_table "ez_proxy_session_id_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "proxy_session_id", null: false
    t.index ["proxy_session_id"], name: "proxy_session_id", unique: true
  end

  create_table "ez_proxy_session_titles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "bibid", limit: 50
    t.string "issn", limit: 50
    t.string "normal_title"
    t.bigint "proxy_session_id", null: false
    t.bigint "resid", null: false
    t.string "title"
  end

  create_table "ez_resources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "alias", limit: 4000
    t.string "bibid", limit: 50
    t.datetime "datecreated"
    t.datetime "datemodified"
    t.string "editor", limit: 25
    t.string "isnum", limit: 50
    t.string "normal_title"
    t.integer "noteid"
    t.integer "resid", null: false
    t.string "suppress", limit: 10, null: false
    t.string "title"
    t.index ["resid"], name: "resid", unique: true
  end

  create_table "ez_skip", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.datetime "date_created", null: false
    t.text "error", limit: 4294967295, null: false
    t.string "file_name", null: false
    t.integer "line_number", null: false
    t.string "type", null: false
    t.index ["type", "line_number", "file_name"], name: "type", unique: true
  end

  create_table "ez_urs_map", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "community", limit: 10, null: false
    t.string "department", limit: 100
    t.string "domain", limit: 4
    t.string "referer", limit: 500
    t.integer "resid"
    t.string "school", limit: 50
    t.integer "sessionid", null: false
    t.datetime "timestamp", null: false
    t.index ["resid"], name: "resid"
    t.index ["sessionid"], name: "sessionid"
    t.index ["timestamp"], name: "timestamp"
  end

  create_table "ezb_bibliography", primary_key: "bibliography_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains resource information", force: :cascade do |t|
    t.string "request_number", limit: 12
    t.string "patron_id", limit: 20, comment: "the unique identifer of the requestor"
    t.string "patron_type", limit: 1, comment: "the role of the requestor"
    t.string "author", limit: 300, comment: "name of the resource provider"
    t.string "title", limit: 400, comment: "the unique book identifer"
    t.string "publisher", limit: 256, comment: "the unique series identifer"
    t.string "publication_place", limit: 256, comment: "the unique hardcopy series identifer"
    t.string "publication_year", limit: 4, comment: "the unique online series identifer"
    t.string "edition", limit: 24, comment: "description of book format"
    t.string "lccn", limit: 32
    t.string "isbn", limit: 24, comment: "unique standard identifier of resource"
    t.string "isbn_2", limit: 24, comment: "alternate unique standard identifier of resource"
    t.integer "oclc"
    t.datetime "request_date", comment: "date the request was first submitted by the patron into the system"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.string "pickup_location", limit: 64, comment: "location of fulfillment acquisition"
    t.integer "borrower", comment: "requesting library identifier"
    t.integer "lender", comment: "fulfilling library identifier "
    t.string "supplier_code", limit: 20, comment: "the shelving location preceded by a two letter code defining the institution"
    t.string "call_number", limit: 256, comment: "specific location identifier of request fulfillment"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.bigint "version", default: 0, null: false
    t.string "local_item_found", limit: 1
    t.string "publication_date"
    t.index ["borrower"], name: "idx_bd_bibliography_borrower"
    t.index ["borrower"], name: "idx_ezb_bibliography_borrower"
    t.index ["lender"], name: "idx_bd_bibliography_lender"
    t.index ["lender"], name: "idx_ezb_bibliography_lender"
    t.index ["request_date"], name: "idx_bd_bibliography_request_date"
    t.index ["request_date"], name: "idx_ezb_bibliography_request_date"
    t.index ["request_number"], name: "idx_ezb_bibliography_request_number"
    t.index ["request_number"], name: "uk_ezb_bibliography_request_number", unique: true
    t.index ["supplier_code"], name: "idx_bd_bibliography_supplier_code"
    t.index ["supplier_code"], name: "idx_ezb_bibliography_supplier_code"
  end

  create_table "ezb_call_number", primary_key: "call_number_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains resource location information", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.integer "holdings_seq", comment: "identifier of fullfillment attempt"
    t.string "supplier_code", limit: 20, comment: "the shelving location preceded by a two letter code defining the institution"
    t.string "call_number", limit: 256, comment: "specific location identifier of request fulfillment"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.bigint "version", default: 0, null: false
    t.index ["request_number"], name: "fk_ezb_call_number_request_number"
    t.index ["request_number"], name: "request_number"
  end

  create_table "ezb_exception_code", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains reasons for changes in request status", force: :cascade do |t|
    t.string "exception_code", limit: 3, default: "", null: false, comment: "code identifier"
    t.string "exception_code_desc", limit: 64, comment: "exception description"
    t.bigint "version", default: 0, null: false
    t.index ["exception_code"], name: "exception_code", unique: true
    t.index ["exception_code_desc"], name: "exception_code_desc", unique: true
  end

  create_table "ezb_institution", primary_key: "library_id", id: :integer, default: nil, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains institution identification", force: :cascade do |t|
    t.string "catalog_code", limit: 1, default: "", null: false, comment: "institution identifier"
    t.string "institution", limit: 64, null: false
    t.bigint "id", null: false, unsigned: true, auto_increment: true
    t.bigint "version", default: 0, null: false
    t.index ["id"], name: "id", unique: true
    t.index ["institution"], name: "institution", unique: true
    t.index ["library_id"], name: "library_id", unique: true
  end

  create_table "ezb_min_ship_date", primary_key: "request_number", id: :string, limit: 12, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.timestamp "min_ship_date", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "ezb_patron_type", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains contains requestor roles", force: :cascade do |t|
    t.string "patron_type", limit: 1, default: "", null: false, comment: "role identifier"
    t.string "patron_type_desc", limit: 32, comment: "role description"
    t.index ["patron_type"], name: "patron_type", unique: true
    t.index ["patron_type_desc"], name: "patron_type_desc", unique: true
  end

  create_table "ezb_print_date", primary_key: "print_date_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains dates request was printed", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.datetime "print_date", comment: "date request was printed"
    t.string "note", limit: 256, comment: "request-specific info"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.integer "library_id"
    t.bigint "version", default: 0, null: false
    t.index ["request_number"], name: "fk_bd_print_date_request_number"
    t.index ["request_number"], name: "fk_ezb_print_date_request_number"
  end

  create_table "ezb_report_distribution", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email_addr", limit: 32, null: false
    t.integer "institution_id", null: false
    t.bigint "version", default: 0, null: false
    t.string "library_id", null: false
    t.index ["id"], name: "id", unique: true
  end

  create_table "ezb_ship_date", primary_key: "ship_date_id", id: :bigint, unsigned: true, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", comment: "contains dates request was shipped and or received", force: :cascade do |t|
    t.string "request_number", limit: 12, comment: "unique identifier for each request"
    t.string "ship_date", limit: 24, comment: "date request was fulfilled"
    t.string "exception_code", limit: 3, comment: "code identifying reason for change in request status"
    t.datetime "process_date", comment: "date the request was first submitted by the patron into the system"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "time record was inserted"
    t.bigint "version", default: 0, null: false
    t.index ["request_number"], name: "idx_bd_ship_date_request_number"
    t.index ["request_number"], name: "idx_ezb_ship_date_request_number"
    t.index ["ship_date"], name: "idx_bd_ship_date_ship_date"
    t.index ["ship_date"], name: "idx_ezb_ship_date_ship_date"
  end

  create_table "ezproxy_hosts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "city", limit: 50
    t.string "country", limit: 50
    t.datetime "date_created", null: false
    t.string "dept"
    t.binary "error", limit: 1, null: false
    t.string "ezproxy_id", limit: 50, null: false
    t.string "file_name", null: false
    t.string "ip_address", limit: 64, null: false
    t.integer "line_number", null: false
    t.string "organization"
    t.string "patron_id", limit: 64
    t.datetime "proxy_date", null: false
    t.integer "proxy_day", null: false
    t.integer "proxy_month", null: false
    t.integer "proxy_year", null: false
    t.string "rank"
    t.string "ref_url_host"
    t.string "state", limit: 50
    t.string "url_host", null: false
    t.binary "valid", limit: 1, null: false
    t.text "validation_error", limit: 4294967295
    t.index ["ezproxy_id"], name: "idx_ez_hosts_ezproxy_id"
    t.index ["file_name"], name: "idx_ez_hosts_file_name"
    t.index ["url_host"], name: "idx_ez_hosts_url_host"
    t.index ["valid"], name: "idx_ez_hosts_valid"
  end

  create_table "funds_list", primary_key: "sumfund_id", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "sumfund_name", limit: 32
  end

  create_table "funds_load", primary_key: "load_id", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "allo_net"
    t.integer "alloc_id"
    t.string "alloc_name", limit: 32
    t.float "available_bal", limit: 53
    t.integer "bib_id"
    t.float "commit_total", limit: 53
    t.float "cost", limit: 53
    t.float "expend_total", limit: 53
    t.integer "inv_line_item_id"
    t.integer "ledger_id"
    t.timestamp "load_time", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "month", limit: 3
    t.float "pending_expen", limit: 53
    t.float "percent", limit: 53
    t.string "po_no", limit: 32
    t.string "publisher", limit: 200
    t.integer "quantity"
    t.integer "repfund_id"
    t.string "repfund_name", limit: 32
    t.string "status", limit: 32
    t.integer "sumfund_id"
    t.string "sumfund_name", limit: 32
    t.string "title"
    t.string "vendor", limit: 32
    t.index ["ledger_id"], name: "funds_load_ledger_id_inx"
    t.index ["status"], name: "funds_load_status_inx"
    t.index ["vendor"], name: "funds_load_vendor_inx"
  end

  create_table "gate_USC", primary_key: "USC_id", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "USC_name", limit: 60
  end

  create_table "gate_affiliation", primary_key: "affiliation_id", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "affiliation_name", limit: 30
  end

  create_table "gate_center", primary_key: "center_id", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "center_name", limit: 30
  end

  create_table "gate_department", primary_key: "department_id", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "department_name", limit: 30
  end

  create_table "gate_door", primary_key: "door_id", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "door_name", limit: 60
    t.string "short_name", limit: 60
    t.integer "id", null: false
    t.bigint "version", null: false
    t.string "name", null: false
  end

  create_table "gate_entry_record", primary_key: "entry_id", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "entry_datetime"
    t.integer "door"
    t.integer "affiliation"
    t.integer "center"
    t.integer "USC"
    t.integer "department"
    t.index ["USC"], name: "USC"
    t.index ["affiliation"], name: "affiliation"
    t.index ["center"], name: "center"
    t.index ["department"], name: "department"
    t.index ["door"], name: "gate_entry_record_ibfk_1_idx"
  end

  create_table "ill_borrowing", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "request_type", null: false
    t.datetime "transaction_date", null: false
    t.bigint "transaction_number", null: false
    t.string "transaction_status", null: false
    t.index ["transaction_number", "transaction_status"], name: "idx_ill_borrowing_transaction_num"
    t.index ["transaction_status"], name: "idx_ill_borrowing_transaction_status"
  end

  create_table "ill_cache", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.datetime "date_created", null: false
    t.text "json_data", limit: 4294967295, null: false
    t.datetime "last_updated", null: false
  end

  create_table "ill_fiscal_start_month", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "month", null: false
  end

  create_table "ill_group", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "group_name", null: false
    t.integer "group_no", null: false
    t.index ["group_no"], name: "group_no", unique: true
  end

  create_table "ill_lender_group", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.integer "demographic"
    t.integer "group_no", null: false
    t.string "lender_code", null: false
    t.index ["lender_code"], name: "idx_ill_lender_group_lender_code"
  end

  create_table "ill_lender_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "address", limit: 328
    t.string "billing_category"
    t.string "lender_code", null: false
    t.string "library_name"
  end

  create_table "ill_lending", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "request_type", null: false
    t.string "status", null: false
    t.datetime "transaction_date", null: false
    t.bigint "transaction_number", null: false
  end

  create_table "ill_lending_tracking", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.datetime "arrival_date"
    t.datetime "completion_date"
    t.string "completion_status"
    t.string "request_type", null: false
    t.bigint "transaction_number", null: false
    t.float "turnaround", limit: 53
    t.index ["transaction_number"], name: "transaction_number", unique: true
  end

  create_table "ill_location", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "abbrev", null: false
    t.string "location", null: false
  end

  create_table "ill_reference_number", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "oclc"
    t.string "ref_number"
    t.string "ref_type"
    t.bigint "transaction_number", null: false
  end

  create_table "ill_tracking", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.datetime "order_date"
    t.string "process_type", null: false
    t.datetime "receive_date"
    t.datetime "request_date"
    t.string "request_type", null: false
    t.datetime "ship_date"
    t.bigint "transaction_number", null: false
    t.float "turnaround_req_rec", limit: 53
    t.float "turnaround_req_shp", limit: 53
    t.float "turnaround_shp_rec", limit: 53
    t.binary "turnarounds_processed", limit: 1, default: "b'0'", null: false
    t.index ["order_date"], name: "idx_ill_tracking_order_date"
    t.index ["ship_date"], name: "idx_ill_tracking_ship_date"
    t.index ["transaction_number"], name: "transaction_number", unique: true
    t.index ["turnarounds_processed"], name: "idx_ill_tracking_turn"
  end

  create_table "ill_transaction", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "billing_amount"
    t.string "call_number"
    t.string "cited_in"
    t.string "esp_number"
    t.string "ifm_cost"
    t.string "in_process_date"
    t.string "issn"
    t.string "lender_codes"
    t.string "lending_library"
    t.string "loan_author"
    t.string "loan_date"
    t.string "loan_edition"
    t.string "loan_location"
    t.string "loan_publisher"
    t.string "loan_title"
    t.string "location"
    t.string "photo_article_author"
    t.string "photo_article_title"
    t.string "photo_journal_inclusive_pages"
    t.string "photo_journal_issue"
    t.string "photo_journal_month"
    t.string "photo_journal_title"
    t.string "photo_journal_volume"
    t.string "photo_journal_year"
    t.string "process_type"
    t.string "reason_for_cancellation"
    t.string "request_type"
    t.string "system_id"
    t.datetime "transaction_date"
    t.bigint "transaction_number", null: false
    t.string "transaction_status"
    t.string "user_id"
    t.bigint "user_name"
    t.string "borrower_nvtgc"
    t.string "original_nvtgc"
    t.index ["transaction_date"], name: "idx_ill_transaction_transaction_date"
    t.index ["transaction_number"], name: "transaction_number", unique: true
  end

  create_table "ill_user_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", default: 0, null: false
    t.string "department"
    t.string "nvtgc"
    t.string "org"
    t.string "rank"
    t.string "user_id", null: false
    t.index ["user_id"], name: "user_id", unique: true
  end

  create_table "job_config", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.text "config", limit: 4294967295
    t.string "trigger_name", null: false
  end

  create_table "job_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "class_to_run"
    t.text "config", limit: 4294967295
    t.string "cron"
    t.text "description", limit: 4294967295
    t.string "job_name", null: false
    t.string "job_trigger", null: false
    t.string "template", null: false
    t.string "url"
    t.string "arguments"
    t.string "stored_script"
    t.index ["job_name"], name: "job_name", unique: true
    t.index ["template"], name: "job_details_template_idx"
  end

  create_table "job_runs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.bigint "details_id", null: false
    t.binary "error", limit: 1, null: false
    t.bigint "finish", null: false
    t.binary "job_log", limit: 16777215
    t.bigint "start", null: false
    t.index ["details_id"], name: "FK9FBB828A4D08A123"
  end

  create_table "job_schedule", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "trigger_name", null: false
    t.string "trigger_type", null: false
    t.index ["trigger_name"], name: "trigger_name", unique: true
  end

  create_table "ldap_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.binary "allow_empty_passwords", limit: 1, null: false
    t.binary "encrypt_strong", limit: 1, null: false
    t.string "encrypted_password"
    t.string "group_search_base"
    t.string "managerdn"
    t.string "rootdn", null: false
    t.string "server", null: false
    t.binary "skip_authentication", limit: 1, null: false
    t.binary "skip_credentials_check", limit: 1, null: false
    t.string "user_search_base", null: false
    t.string "user_search_filter", null: false
    t.string "group_search_filter", null: false
  end

  create_table "ldap_role_mapping", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "ldap_role_mapping_shiro_role", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "ldap_role_mapping_roles_id"
    t.bigint "shiro_role_id"
    t.index ["ldap_role_mapping_roles_id"], name: "FKE029BE6BDEEE42A"
    t.index ["shiro_role_id"], name: "FKE029BE6E074BD57"
  end

  create_table "manage_report", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "controller_name", null: false
    t.binary "is_protected", limit: 1, null: false
    t.index ["controller_name"], name: "idx_report_permissions_controller_name"
  end

  create_table "manage_report_shiro_role", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "manage_report_roles_id"
    t.bigint "shiro_role_id"
    t.index ["manage_report_roles_id"], name: "FK47F0299584B3E4F"
    t.index ["shiro_role_id"], name: "FK47F029953B1CA345"
  end

  create_table "notification_emails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "email", null: false
    t.string "scope", null: false
    t.index ["scope", "email"], name: "scope", unique: true
  end

  create_table "remember_cookie_age", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "age_in_seconds", null: false
  end

  create_table "report_permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "controller_name", null: false
    t.binary "is_protected", limit: 1, null: false
    t.index ["controller_name"], name: "idx_report_permissions_controller_name"
  end

  create_table "report_permissions_shiro_role", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "report_permissions_roles_id"
    t.bigint "shiro_role_id"
    t.index ["report_permissions_roles_id"], name: "FK7C27F00A6B8C36B"
    t.index ["shiro_role_id"], name: "FK7C27F00A3B1CA345"
  end

  create_table "rid_audience", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_cons_transaction", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "course_name", limit: 100
    t.string "course_number", limit: 100
    t.bigint "course_sponsor_id"
    t.datetime "date_of_consultation", null: false
    t.bigint "department_id"
    t.integer "event_length", null: false
    t.string "faculty_sponsor", limit: 100
    t.integer "interact_occurrences", null: false
    t.bigint "mode_of_consultation_id", null: false
    t.string "notes", limit: 500
    t.string "other_rank", limit: 50
    t.integer "prep_time", null: false
    t.bigint "rank_id", null: false
    t.bigint "rid_library_unit_id", null: false
    t.bigint "school_id"
    t.bigint "service_provided_id", null: false
    t.string "spreadsheet_name"
    t.string "staff_pennkey", limit: 100, null: false
    t.bigint "user_goal_id"
    t.string "user_name", limit: 50
    t.string "user_question", limit: 500
    t.bigint "expertise_id"
    t.index ["course_sponsor_id"], name: "FKF73AE3C2FAFC0B60"
    t.index ["department_id"], name: "FKF73AE3C248229FBD"
    t.index ["expertise_id"], name: "FKF73AE3C291C3B077"
    t.index ["mode_of_consultation_id"], name: "FKF73AE3C282AF530B"
    t.index ["rank_id"], name: "FKF73AE3C2E83427BD"
    t.index ["rid_library_unit_id"], name: "FKF73AE3C269ECFC"
    t.index ["school_id"], name: "FKF73AE3C2DBEF2DFD"
    t.index ["service_provided_id"], name: "FKF73AE3C26E1630C2"
    t.index ["user_goal_id"], name: "FKF73AE3C2CD628AD4"
  end

  create_table "rid_cons_transaction_template", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "course_name", null: false
    t.string "course_number", null: false
    t.bigint "course_sponsor_id", null: false
    t.datetime "date_of_consultation", null: false
    t.bigint "department_id", null: false
    t.integer "event_length", null: false
    t.string "faculty_sponsor", null: false
    t.integer "interact_occurrences", null: false
    t.bigint "mode_of_consultation_id", null: false
    t.string "notes", null: false
    t.integer "prep_time", null: false
    t.bigint "rank_id", null: false
    t.bigint "rid_library_unit_id", null: false
    t.bigint "school_id", null: false
    t.bigint "service_provided_id", null: false
    t.string "staff_pennkey", null: false
    t.string "template_owner", null: false
    t.bigint "user_goal_id", null: false
    t.string "user_name", null: false
    t.string "user_question", null: false
    t.string "other_rank", null: false
    t.string "other_expertise", null: false
    t.index ["course_sponsor_id"], name: "FK7F9C3457FAFC0B60"
    t.index ["department_id"], name: "FK7F9C345748229FBD"
    t.index ["mode_of_consultation_id"], name: "FK7F9C345782AF530B"
    t.index ["rank_id"], name: "FK7F9C3457E83427BD"
    t.index ["rid_library_unit_id"], name: "FK7F9C345769ECFC"
    t.index ["school_id"], name: "FK7F9C3457DBEF2DFD"
    t.index ["service_provided_id"], name: "FK7F9C34576E1630C2"
    t.index ["user_goal_id"], name: "FK7F9C3457CD628AD4"
  end

  create_table "rid_course_sponsor", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_department", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "full_name"
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_departmental_affiliation", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_expertise", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", limit: 150, null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_ins_transaction", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "attendance_total", null: false
    t.string "co_instructor_pennkey", limit: 100
    t.string "course_name", limit: 100
    t.string "course_number", limit: 100
    t.datetime "date_of_instruction", null: false
    t.bigint "department_id"
    t.integer "event_length", null: false
    t.bigint "expertise_id"
    t.string "faculty_sponsor", limit: 100
    t.bigint "instructional_materials_id"
    t.string "instructor_pennkey", limit: 100, null: false
    t.bigint "location_id", null: false
    t.text "notes", limit: 4294967295
    t.integer "prep_time", null: false
    t.string "requestor", limit: 50
    t.bigint "rid_library_unit_id", null: false
    t.bigint "school_id"
    t.string "sequence_name", limit: 100
    t.integer "sequence_unit"
    t.text "session_description", limit: 4294967295
    t.bigint "session_type_id", null: false
    t.string "spreadsheet_name"
    t.index ["department_id"], name: "FKD4E5A8DB48229FBD"
    t.index ["expertise_id"], name: "FKD4E5A8DB91C3B077"
    t.index ["instructional_materials_id"], name: "FKD4E5A8DB4015B10A"
    t.index ["location_id"], name: "FKD4E5A8DB901159D"
    t.index ["rid_library_unit_id"], name: "FKD4E5A8DB69ECFC"
    t.index ["school_id"], name: "FKD4E5A8DBDBEF2DFD"
    t.index ["session_type_id"], name: "FKD4E5A8DBCBB97FA4"
  end

  create_table "rid_ins_transaction_template", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "attendance_total"
    t.string "co_instructor_pennkey", limit: 100
    t.string "course_name", limit: 100
    t.string "course_number", limit: 100
    t.datetime "date_of_instruction", null: false
    t.bigint "department_id"
    t.integer "event_length"
    t.bigint "expertise_id"
    t.string "faculty_sponsor", limit: 100
    t.bigint "instructional_materials_id"
    t.string "instructor_pennkey", limit: 100, null: false
    t.bigint "location_id"
    t.text "notes", limit: 4294967295
    t.integer "prep_time"
    t.string "requestor", limit: 50
    t.bigint "rid_library_unit_id"
    t.bigint "school_id"
    t.string "sequence_name", limit: 100
    t.integer "sequence_unit"
    t.text "session_description", limit: 4294967295
    t.bigint "session_type_id"
    t.string "template_owner", null: false
    t.index ["department_id"], name: "FKC06B1B5E48229FBD"
    t.index ["expertise_id"], name: "FKC06B1B5E91C3B077"
    t.index ["instructional_materials_id"], name: "FKC06B1B5E4015B10A"
    t.index ["location_id"], name: "FKC06B1B5E901159D"
    t.index ["rid_library_unit_id"], name: "FKC06B1B5E69ECFC"
    t.index ["school_id"], name: "FKC06B1B5EDBEF2DFD"
    t.index ["session_type_id"], name: "FKC06B1B5ECBB97FA4"
  end

  create_table "rid_instructional_materials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.bigint "rid_library_unit_id"
    t.index ["rid_library_unit_id"], name: "FKEEF87B7469ECFC"
  end

  create_table "rid_library_unit", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_location", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.bigint "rid_library_unit_id"
    t.index ["rid_library_unit_id"], name: "FK624DF6A769ECFC"
  end

  create_table "rid_mode_of_consultation", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.bigint "rid_report_type_id"
    t.bigint "rid_library_unit_id"
    t.index ["rid_library_unit_id"], name: "FK26C8094769ECFC"
    t.index ["rid_report_type_id"], name: "FK26C809475033A778"
  end

  create_table "rid_rank", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_rank_rid_ins_transaction", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "rid_rank_rid_ins_transaction_id"
    t.bigint "rid_ins_transaction_id"
    t.index ["rid_ins_transaction_id"], name: "FKB6FBE73ACB1606D2"
    t.index ["rid_rank_rid_ins_transaction_id"], name: "FKB6FBE73ABA2A09EF"
  end

  create_table "rid_report_type", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_school", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_service_provided", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.bigint "rid_report_type_id"
    t.bigint "rid_library_unit_id"
    t.index ["rid_library_unit_id"], name: "FK6E0A711F69ECFC"
    t.index ["rid_report_type_id"], name: "FK6E0A711F5033A778"
  end

  create_table "rid_session_type", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.bigint "rid_library_unit_id"
    t.index ["rid_library_unit_id"], name: "FKE24E813569ECFC"
  end

  create_table "rid_statistics_graph_report", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "transaction_sum", null: false
  end

  create_table "rid_statistics_graph_report_trans_by_date", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "trans_by_date"
    t.string "trans_by_date_idx"
    t.string "trans_by_date_elt", null: false
  end

  create_table "rid_statistics_report", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "avg_event_length", null: false
    t.integer "avg_interact_occurrences", null: false
    t.integer "avg_prep_time", null: false
    t.integer "courses_added", null: false
    t.integer "pennkey_max", null: false
    t.string "staff_pennkey", null: false
    t.integer "total_event_length", null: false
    t.integer "total_interact_occurences", null: false
    t.integer "total_prep_time", null: false
    t.integer "total_transactions", null: false
    t.integer "year_event_length", null: false
    t.integer "year_interact_occurences", null: false
    t.integer "year_prep_time", null: false
    t.integer "year_transactions", null: false
  end

  create_table "rid_statistics_search_report", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "transaction_sum", null: false
  end

  create_table "rid_test", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "test", limit: 150, null: false
    t.index ["test"], name: "test", unique: true
  end

  create_table "rid_test_rid_cons_transaction", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "rid_test_rid_cons_transaction_id"
    t.bigint "rid_cons_transaction_id"
    t.index ["rid_cons_transaction_id"], name: "FK7DFED49DD76B3C42"
    t.index ["rid_test_rid_cons_transaction_id"], name: "FK7DFED49DE7D1F612"
  end

  create_table "rid_test_rid_ins_transaction", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "rid_test_rid_ins_transaction_id"
    t.bigint "rid_ins_transaction_id"
    t.index ["rid_ins_transaction_id"], name: "FKE9C2B0A0CB1606D2"
    t.index ["rid_test_rid_ins_transaction_id"], name: "FKE9C2B0A0A531F72F"
  end

  create_table "rid_transaction", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "course_name", limit: 100
    t.string "course_number", limit: 100
    t.bigint "course_sponsor_id", null: false
    t.datetime "date_of_consultation", null: false
    t.bigint "departmental_affilication_id", null: false
    t.integer "event_length", null: false
    t.string "faculty_sponsor", limit: 300
    t.string "follow_up_contact", limit: 50
    t.integer "interact_times", null: false
    t.string "librarian", limit: 100
    t.bigint "mode_of_consultation_id", null: false
    t.string "notes", limit: 500
    t.string "patron_email", limit: 100
    t.integer "prep_time", null: false
    t.bigint "rid_report_type_id", null: false
    t.bigint "service_provided_id", null: false
    t.string "staff_pennkey", limit: 100, null: false
    t.binary "template", limit: 1, null: false
    t.bigint "user_id", null: false
    t.bigint "user_affiliation_id", null: false
    t.bigint "user_goal_id"
    t.string "user_question", limit: 500, null: false
    t.string "spreadsheet_name"
    t.index ["course_sponsor_id"], name: "FK2D68BEACFAFC0B60"
    t.index ["departmental_affilication_id"], name: "FK2D68BEAC4AB68A91"
    t.index ["mode_of_consultation_id"], name: "FK2D68BEAC82AF530B"
    t.index ["rid_report_type_id"], name: "FK2D68BEAC5033A778"
    t.index ["service_provided_id"], name: "FK2D68BEAC6E1630C2"
    t.index ["user_affiliation_id"], name: "FK2D68BEAC6886A880"
    t.index ["user_goal_id"], name: "FK2D68BEACCD628AD4"
    t.index ["user_id"], name: "FK2D68BEACA5240F5D"
  end

  create_table "rid_user", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_user_affiliation", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "rid_user_goal", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.integer "in_form", null: false
    t.string "name", null: false
    t.bigint "rid_report_type_id"
    t.bigint "rid_library_unit_id"
    t.index ["rid_library_unit_id"], name: "FK43037A5569ECFC"
    t.index ["rid_report_type_id"], name: "FK43037A555033A778"
  end

  create_table "shiro_role", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "name", null: false
    t.index ["name"], name: "name", unique: true
  end

  create_table "shiro_role_permissions", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "shiro_role_id"
    t.string "permissions_string"
    t.index ["shiro_role_id"], name: "FK389B46C93B1CA345"
  end

  create_table "shiro_user", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "email_address"
    t.string "password_hash", null: false
    t.string "username", null: false
    t.index ["email_address"], name: "email_address", unique: true
    t.index ["username"], name: "username", unique: true
  end

  create_table "shiro_user_permissions", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "shiro_user_id"
    t.string "permissions_string"
    t.index ["shiro_user_id"], name: "FK34555A9EE0476725"
  end

  create_table "shiro_user_roles", primary_key: ["shiro_user_id", "shiro_role_id"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "shiro_user_id", null: false
    t.bigint "shiro_role_id", null: false
    t.index ["shiro_role_id"], name: "FKBA2210573B1CA345"
    t.index ["shiro_user_id"], name: "FKBA221057E0476725"
  end

  create_table "validate_counts", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "data_store", limit: 24, null: false
    t.string "data_group", limit: 24, null: false
    t.integer "source_count", default: 0, null: false
    t.integer "load_count", default: 0, null: false
    t.index ["data_store", "data_group"], name: "idx_data_store_data_group", unique: true
  end

  create_table "vendor", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.string "vendor_code", limit: 20, null: false
    t.string "vendor_name", limit: 100, null: false
    t.index ["vendor_code"], name: "vendor_v_code_inx"
  end

  create_table "wfrn_dig_obj_log", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "version", null: false
    t.datetime "date_created", null: false
    t.datetime "log_date", null: false
    t.integer "log_line", null: false
    t.string "log_name", null: false
    t.string "object_id", null: false
    t.string "requested_file", null: false
  end

  create_table "work_table", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "data_store", limit: 12, default: "", null: false, collation: "latin1_swedish_ci"
    t.string "data_group", limit: 10, collation: "latin1_swedish_ci"
    t.bigint "group_count", default: 0, null: false
  end

  add_foreign_key "controller_data", "app_category", column: "category_id", name: "FKE825266DC19009D5"
  add_foreign_key "ered_person", "ered_rank", column: "rank_id", name: "FK720CF0E57A858686"
  add_foreign_key "ered_person_loading", "ered_rank", column: "rank_id", name: "FK37D0E87A858686"
  add_foreign_key "ez_doi", "ez_doi_journal", name: "FKB33D5EB4C6BC072B"
  add_foreign_key "ez_proxy_session_id", "ez_proxy_session_id_data", column: "ez_proxy_session_id_data_id", name: "FK77C6F01FBA102D01"
  add_foreign_key "gate_entry_record", "gate_USC", column: "USC", primary_key: "USC_id", name: "gate_entry_record_ibfk_4"
  add_foreign_key "gate_entry_record", "gate_affiliation", column: "affiliation", primary_key: "affiliation_id", name: "gate_entry_record_ibfk_2"
  add_foreign_key "gate_entry_record", "gate_center", column: "center", primary_key: "center_id", name: "gate_entry_record_ibfk_3"
  add_foreign_key "gate_entry_record", "gate_department", column: "department", primary_key: "department_id", name: "gate_entry_record_ibfk_5"
  add_foreign_key "gate_entry_record", "gate_door", column: "door", primary_key: "door_id", name: "gate_entry_record_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "job_runs", "job_details", column: "details_id", name: "FK9FBB828A4D08A123"
  add_foreign_key "ldap_role_mapping_shiro_role", "ldap_role_mapping", column: "ldap_role_mapping_roles_id", name: "FKE029BE6BDEEE42A"
  add_foreign_key "ldap_role_mapping_shiro_role", "shiro_role", name: "FKE029BE6E074BD57"
  add_foreign_key "manage_report_shiro_role", "manage_report", column: "manage_report_roles_id", name: "FK47F0299584B3E4F"
  add_foreign_key "manage_report_shiro_role", "shiro_role", name: "FK47F029953B1CA345"
  add_foreign_key "report_permissions_shiro_role", "report_permissions", column: "report_permissions_roles_id", name: "FK7C27F00A6B8C36B"
  add_foreign_key "report_permissions_shiro_role", "shiro_role", name: "FK7C27F00A3B1CA345"
  add_foreign_key "rid_cons_transaction", "rid_course_sponsor", column: "course_sponsor_id", name: "FKF73AE3C2FAFC0B60"
  add_foreign_key "rid_cons_transaction", "rid_department", column: "department_id", name: "FKF73AE3C248229FBD"
  add_foreign_key "rid_cons_transaction", "rid_expertise", column: "expertise_id", name: "FKF73AE3C291C3B077"
  add_foreign_key "rid_cons_transaction", "rid_library_unit", name: "FKF73AE3C269ECFC"
  add_foreign_key "rid_cons_transaction", "rid_mode_of_consultation", column: "mode_of_consultation_id", name: "FKF73AE3C282AF530B"
  add_foreign_key "rid_cons_transaction", "rid_rank", column: "rank_id", name: "FKF73AE3C2E83427BD"
  add_foreign_key "rid_cons_transaction", "rid_school", column: "school_id", name: "FKF73AE3C2DBEF2DFD"
  add_foreign_key "rid_cons_transaction", "rid_service_provided", column: "service_provided_id", name: "FKF73AE3C26E1630C2"
  add_foreign_key "rid_cons_transaction", "rid_user_goal", column: "user_goal_id", name: "FKF73AE3C2CD628AD4"
  add_foreign_key "rid_cons_transaction_template", "rid_course_sponsor", column: "course_sponsor_id", name: "FK7F9C3457FAFC0B60"
  add_foreign_key "rid_cons_transaction_template", "rid_department", column: "department_id", name: "FK7F9C345748229FBD"
  add_foreign_key "rid_cons_transaction_template", "rid_library_unit", name: "FK7F9C345769ECFC"
  add_foreign_key "rid_cons_transaction_template", "rid_mode_of_consultation", column: "mode_of_consultation_id", name: "FK7F9C345782AF530B"
  add_foreign_key "rid_cons_transaction_template", "rid_rank", column: "rank_id", name: "FK7F9C3457E83427BD"
  add_foreign_key "rid_cons_transaction_template", "rid_school", column: "school_id", name: "FK7F9C3457DBEF2DFD"
  add_foreign_key "rid_cons_transaction_template", "rid_service_provided", column: "service_provided_id", name: "FK7F9C34576E1630C2"
  add_foreign_key "rid_cons_transaction_template", "rid_user_goal", column: "user_goal_id", name: "FK7F9C3457CD628AD4"
  add_foreign_key "rid_ins_transaction", "rid_department", column: "department_id", name: "FKD4E5A8DB48229FBD"
  add_foreign_key "rid_ins_transaction", "rid_expertise", column: "expertise_id", name: "FKD4E5A8DB91C3B077"
  add_foreign_key "rid_ins_transaction", "rid_instructional_materials", column: "instructional_materials_id", name: "FKD4E5A8DB4015B10A"
  add_foreign_key "rid_ins_transaction", "rid_library_unit", name: "FKD4E5A8DB69ECFC"
  add_foreign_key "rid_ins_transaction", "rid_location", column: "location_id", name: "FKD4E5A8DB901159D"
  add_foreign_key "rid_ins_transaction", "rid_school", column: "school_id", name: "FKD4E5A8DBDBEF2DFD"
  add_foreign_key "rid_ins_transaction", "rid_session_type", column: "session_type_id", name: "FKD4E5A8DBCBB97FA4"
  add_foreign_key "rid_ins_transaction_template", "rid_department", column: "department_id", name: "FKC06B1B5E48229FBD"
  add_foreign_key "rid_ins_transaction_template", "rid_expertise", column: "expertise_id", name: "FKC06B1B5E91C3B077"
  add_foreign_key "rid_ins_transaction_template", "rid_instructional_materials", column: "instructional_materials_id", name: "FKC06B1B5E4015B10A"
  add_foreign_key "rid_ins_transaction_template", "rid_library_unit", name: "FKC06B1B5E69ECFC"
  add_foreign_key "rid_ins_transaction_template", "rid_location", column: "location_id", name: "FKC06B1B5E901159D"
  add_foreign_key "rid_ins_transaction_template", "rid_school", column: "school_id", name: "FKC06B1B5EDBEF2DFD"
  add_foreign_key "rid_ins_transaction_template", "rid_session_type", column: "session_type_id", name: "FKC06B1B5ECBB97FA4"
  add_foreign_key "rid_instructional_materials", "rid_library_unit", name: "FKEEF87B7469ECFC"
  add_foreign_key "rid_location", "rid_library_unit", name: "FK624DF6A769ECFC"
  add_foreign_key "rid_mode_of_consultation", "rid_library_unit", name: "FK26C8094769ECFC"
  add_foreign_key "rid_mode_of_consultation", "rid_report_type", name: "FK26C809475033A778"
  add_foreign_key "rid_rank_rid_ins_transaction", "rid_ins_transaction", name: "FKB6FBE73ACB1606D2"
  add_foreign_key "rid_rank_rid_ins_transaction", "rid_rank", column: "rid_rank_rid_ins_transaction_id", name: "FKB6FBE73ABA2A09EF"
  add_foreign_key "rid_service_provided", "rid_library_unit", name: "FK6E0A711F69ECFC"
  add_foreign_key "rid_service_provided", "rid_report_type", name: "FK6E0A711F5033A778"
  add_foreign_key "rid_session_type", "rid_library_unit", name: "FKE24E813569ECFC"
  add_foreign_key "rid_test_rid_cons_transaction", "rid_cons_transaction", name: "FK7DFED49DD76B3C42"
  add_foreign_key "rid_test_rid_cons_transaction", "rid_test", column: "rid_test_rid_cons_transaction_id", name: "FK7DFED49DE7D1F612"
  add_foreign_key "rid_test_rid_ins_transaction", "rid_ins_transaction", name: "FKE9C2B0A0CB1606D2"
  add_foreign_key "rid_test_rid_ins_transaction", "rid_test", column: "rid_test_rid_ins_transaction_id", name: "FKE9C2B0A0A531F72F"
  add_foreign_key "rid_transaction", "rid_course_sponsor", column: "course_sponsor_id", name: "FK2D68BEACFAFC0B60"
  add_foreign_key "rid_transaction", "rid_departmental_affiliation", column: "departmental_affilication_id", name: "FK2D68BEAC4AB68A91"
  add_foreign_key "rid_transaction", "rid_mode_of_consultation", column: "mode_of_consultation_id", name: "FK2D68BEAC82AF530B"
  add_foreign_key "rid_transaction", "rid_report_type", name: "FK2D68BEAC5033A778"
  add_foreign_key "rid_transaction", "rid_service_provided", column: "service_provided_id", name: "FK2D68BEAC6E1630C2"
  add_foreign_key "rid_transaction", "rid_user", column: "user_id", name: "FK2D68BEACA5240F5D"
  add_foreign_key "rid_transaction", "rid_user_affiliation", column: "user_affiliation_id", name: "FK2D68BEAC6886A880"
  add_foreign_key "rid_transaction", "rid_user_goal", column: "user_goal_id", name: "FK2D68BEACCD628AD4"
  add_foreign_key "rid_user_goal", "rid_library_unit", name: "FK43037A5569ECFC"
  add_foreign_key "rid_user_goal", "rid_report_type", name: "FK43037A555033A778"
  add_foreign_key "shiro_role_permissions", "shiro_role", name: "FK389B46C93B1CA345"
  add_foreign_key "shiro_user_permissions", "shiro_user", name: "FK34555A9EE0476725"
  add_foreign_key "shiro_user_roles", "shiro_role", name: "FKBA2210573B1CA345"
  add_foreign_key "shiro_user_roles", "shiro_user", name: "FKBA221057E0476725"
end
