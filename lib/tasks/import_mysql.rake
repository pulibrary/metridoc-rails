namespace :import do
  namespace :mysql do

    desc "Generate migration code for borrrowdirect and save into a target file"
    task :generate_borrrowdirect_migration, [:output_file_path] => [:environment]  do |_t, args|
      generate_migration("database_borrrowdirect.yml", args[:output_file_path], 'bd_')
    end

    desc "Generate migration code for ezborrow and save into a target file"
    task :generate_ezborrow_migration, [:output_file_path] => [:environment]  do |_t, args|
      generate_migration("database_ezborrow.yml", args[:output_file_path], 'ezb_')
    end

    desc "Generate migration code for ILLiad and save into a target file"
    task :generate_illiad_migration, [:output_file_path] => [:environment]  do |_t, args|
      generate_migration("database_illiad.yml", args[:output_file_path], 'ill_')
    end

    desc "Copy data from mysql into app database"
    task :copy_mysql_data => [:environment]  do |_t, args|
      copy_mysql_data("database_ezborrow.yml", 'ezb_', 'Ezborrow')
    end

  end
end

def log(m)
  puts "#{Time.now} - #{m}"
end

def copy_mysql_data(db_yml_name, prefix, namespace)

  mysql_db = YAML.load_file(File.join(Rails.root, "config", db_yml_name))[Rails.env.to_s] 

  connection = ActiveRecord::Base.establish_connection(mysql_db).connection

  tables_exported = []

  require "csv"

  table_results = connection.select_all("SHOW TABLES LIKE '#{prefix}%';")
  table_results.each do |tr|
    table_name = tr.values.first


    primary_keys = []
    column_results = connection.select_all("SHOW COLUMNS FROM #{table_name} WHERE `Key` = 'PRI';")
    column_results.each do |cr|
      primary_keys << cr["Field"]
    end

    csv_file_path = "tmp/#{table_name}.csv"

    row_results = connection.select_all("SELECT * FROM #{table_name};")

    CSV.open(csv_file_path, "wb") do |csv|
      if row_results.count > 0
        csv << (row_results.first.keys - primary_keys)
      end
      row_results.each do |row|
        csv << row.except(*primary_keys).values
      end
    end

    tables_exported << {table_name: table_name, csv_file_path: csv_file_path}
  end

  connection.close

  app_db = YAML.load_file(File.join(Rails.root, "config", "database.yml"))[Rails.env.to_s] 
  connection = ActiveRecord::Base.establish_connection(app_db).connection

  tables_exported.each do |table_exported|
    table_name = table_exported[:table_name]
    csv_file_path = table_exported[:csv_file_path]

    class_name = "#{namespace}::#{table_name[prefix.length..-1].singularize.classify}".constantize

    csv = CSV.read(csv_file_path)

    headers = csv.first

    records = []
    n_errors = 0
    csv.drop(1).each_with_index do |row, n|
      if n_errors >= 100
        log "Too may errors #{n_errors}, exiting!"
        records = []
        break
      end
      z = {}
      headers.each_with_index do |k,i| 
        v = row[i]
        z[k.underscore.to_sym] = v
      end
      records << class_name.new(z)

      if records.size >= 10000
        class_name.import records
        log "Imported #{records.size} records from #{table_name}"
        records = []
      end
    end
    if records.size > 0
      class_name.import records
      log "Imported #{records.size} records from #{table_name}"
    end
    log "#{n_errors} errors with #{table_name}" if n_errors > 0
    log "Finished importing #{table_name}"

  end

end

def convert_column_type(t)
  return [:integer, 8] if /bigint\(/.match(t)
  return [:integer, nil] if /int\(/.match(t)
  return [:boolean, nil] if /bit\(1\)/.match(t)
  return [:datetime, nil] if /datetime/.match(t)
  return [:timestamp, nil] if /timestamp/.match(t)
  return [:text, nil] if /longtext/.match(t)
  return [:float, nil] if /double/.match(t)

  m = /varchar\((\d+)\)/.match(t)
  if m.present?
    return [:string, m[1].to_i]
  end

  m = /char\((\d+)\)/.match(t)
  if m.present?
    return [:string, m[1].to_i]
  end

  raise "unable to find type for #{t}"
end


def generate_migration(db_yml_name, output_file_path, prefix)
  first_line = File.open(output_file_path) {|f| f.readline}

  output_file = File.open(output_file_path, "w")

  mysql_db = YAML.load_file(File.join(Rails.root, "config", db_yml_name))[Rails.env.to_s] 

  connection = ActiveRecord::Base.establish_connection(mysql_db).connection

  output_file.puts first_line

  output_file.puts "  def change"
  table_results = connection.select_all("SHOW TABLES LIKE '#{prefix}%';")
  table_results.each do |tr|
    table_name = tr.values.first

    column_results = connection.select_all("SHOW COLUMNS FROM #{table_name};")

    output_file.puts "    create_table :#{table_name.pluralize} do |t|"
    column_results.each do |cr|
      field = cr["Field"]
      type = cr["Type"]
      null = cr["Null"]
      key = cr["Key"]
      default = cr["Default"]
      extra = cr["Extra"]

      # log cr.inspect

      column_type, limit = convert_column_type(type)

      next if (key == "PRI" || (field == 'id' && extra == 'auto_increment') ) && column_type == :integer

      column_definition = "      t.#{column_type.to_s} :#{field} "
      column_definition += ", limit: #{limit}" if limit
      column_definition += ", null: false" if null == "NO"

      output_file.puts column_definition
    end
    output_file.puts "    end"
    output_file.puts ""

  end
  output_file.puts "  end"
  output_file.puts "end"

  output_file.close
  log "Successfully finished generating schema into #{output_file_path}"
end