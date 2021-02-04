# frozen_string_literal: true
require "csv"
require 'chronic'

# rubocop:disable Metrics/ClassLength
module Import
  class Task
    HEADER_CONVERTER = ->(header) { Util.column_to_attribute(header).to_sym }

    def initialize(main_driver, task_file, test_mode = false, google_drive: nil)
      @main_driver = main_driver
      @task_file = task_file
      @test_mode = test_mode
      @google_drive = google_drive
    end

    def log_job_execution
      @main_driver.log_job_execution
    end

    def log_job_execution_step
      return @log_job_execution_step if @log_job_execution_step.present?

      @log_job_execution_step = log_job_execution.job_execution_steps.create!(
                                                        step_name: task_config["load_sequence"],
                                                        step_yml: task_config,
                                                        started_at: Time.zone.now,
                                                        status: 'running'
                                                      )
    end

    def global_config
      @main_driver.global_config
    end

    def institution_id
      @main_driver.institution_id
    end

    def truncate_before_load?
      task_config["truncate_before_load"] == "yes"
    end

    def target_mappings(headers = nil)
      return @target_mappings if @target_mappings.present?

      return @target_mappings = task_config['target_mappings'] if task_config['target_mappings'].present?

      @target_mappings = if task_config["column_mappings"].present?
                           task_config["column_mappings"].map { |_column, target_column| { target_column.to_s.strip => target_column.to_s.strip } }.inject(:merge)
                         else
                           headers.map { |column| class_name.has_attribute?(column.underscore) ? { column.to_s.strip.underscore => column.to_s.strip.underscore } : nil }.compact.inject(:merge)
                         end

      @target_mappings
    end

    def task_config
      return @task_config if @task_config.present?
      @task_config = global_config.merge(YAML.safe_load(ERB.new(File.read(@task_file)).result))
    end

    def target_adapter
      task_config["target_adapter"] || task_config["adapter"]
    end

    def execute
      log_job_execution_step

      return_value = false
      if target_adapter == "csv"
        return_value = import_csv
      elsif target_adapter == "xml"
        return_value = import_xml
      elsif target_adapter == "native_sql"
        return_value = execute_native_query
      elsif target_adapter == "console_command"
        return_value = execute_console_command
      elsif target_adapter == "google_sheet"
        return_value = import_google_sheet
      elsif target_adapter == "google_csv"
        return_value = import_google_csv
      else
        raise "Unsupported target_adapter type >> #{target_adapter}"
      end

      if return_value
        log_job_execution_step.set_status!("successful")
      else
        log_job_execution_step.set_status!("failed")
      end

      return_value

    rescue => ex
      log "Error => [#{ex.message}]"
      log_job_execution_step.set_status!("failed")
      false
    end

    def batch_size
      @test_mode ? 100 : task_config["batch_size"] || 10_000
    end

    def max_errors
      2000
    end

    def class_name
      return @class_name if @class_name.present?
      @class_name = task_config["target_model"].constantize
    end

    def has_institution_id?
      class_name.has_attribute?('institution_id')
    end

    def has_legacy_flag?
      class_name.has_attribute?('is_legacy')
    end

    def legacy_filter_date_field
      task_config["legacy_filter_date_field"]
    end

    def truncate
      filters = {}
      filters[:institution_id] = institution_id if has_institution_id?

      if has_legacy_flag? && task_config["truncate_legacy_data"] != "yes"
        filters[:is_legacy] = false
        # mark records older than 1 year old as legacy
        if legacy_filter_date_field.present?
          log "Setting Legacy Flag for #{class_name.name} records older than 1 year."
          class_name.where(filters).where(class_name.arel_table[legacy_filter_date_field].lt(1.year.ago)).update_all(is_legacy: true)
        end
      end

      class_name.where(filters).delete_all
    end

    def sqls
      return @sqls if @sqls.present?
      @sqls = task_config["sqls"].presence || [task_config["sql"]]
    end

    def commands
      return @commands if @commands.present?
      @commands = task_config["commands"].presence || [task_config["command"]]
    end

    def execute_console_command
      commands.each do |cmd|
        log "Executing: #{cmd}"
        unless system(cmd)
          log "Command #{cmd} Failed."
          return false
        end
      end

      true
    end

    def execute_native_query
      truncate if truncate_before_load?

      sqls.each do |sql|
        sql = format(sql, institution_id: institution_id)
        log "Executing Query [#{sql}]"
        ActiveRecord::Base.connection.execute(sql)
      end

      true
    end

    def import_file_name
      task_config["import_file_name"] || task_config["export_file_name"] || task_config["file_name"]
    end

    def csv_file_path
      @csv_file_path ||= File.join(@main_driver.import_folder, import_file_name)
    end

    def import_csv
      Util.convert_to_utf8(csv_file_path)
      csv = CSV.open(csv_file_path, headers: true, header_converters: HEADER_CONVERTER)
      import_csv_data(csv)
    end

    def import_records(records)
      result = class_name.import records
      log "Imported #{result.ids.size} records."
      log_validation_errors(result.failed_instances)
      result.failed_instances.size
    rescue
      log "Error on import. Query too large to display."
      save_records_individually(records)
    end

    def save_records_individually(records)
      n_errors = 0
      log "Switching to individual mode"
      records.each do |record|
        unless record.save
          log "Failed saving #{record.inspect} error: #{record.errors.full_messages.join(', ')}"
          n_errors += 1
        end
      rescue => ex
        log "Error => #{ex.message} record:[#{record.inspect}]"
        n_errors += 1
        # record.attribute_names.each do |a|
        #   log "#{a} --- #{record.send(a).size rescue "n/a"} "
        # end
      end

      n_errors
    end

    def iterator_path
      task_config["iterator_path"]
    end

    def import_xml
      log "Starting to import XML #{import_file_name}"

      xml_file_path = File.join(@main_driver.import_folder, import_file_name)

      truncate if truncate_before_load?

      doc = Nokogiri::XML(File.open(xml_file_path))
      doc.remove_namespaces!
      records = []
      n_errors = 0
      doc.xpath(iterator_path).each do |xml_row|
        row_error = false
        atts = {}
        atts[:institution_id] = institution_id if has_institution_id?
        target_mappings.each do |column_name, x_path|
          node = xml_row.xpath(x_path)
          val = node.is_a?(Nokogiri::XML::NodeSet) ? (node.present? ? node.first.text : "") : node
          atts[column_name] = val.gsub(/\s+/, ' ').to_s.strip
        end

        next if row_error

        records << class_name.new(atts)

        next unless records.size >= batch_size
        n_errors += import_records(records)
        records = []
        break if @test_mode
      end

      unless records.empty?
        n_errors += import_records(records)
        records = []
      end

      log "#{n_errors} errors" if n_errors > 0
      log "Finished importing XML #{import_file_name}."

      true
    end

    def log_validation_errors(records)
      records.each do |r|
        log "Failed saving #{r.inspect} error: #{r.errors.full_messages.join(', ')}"
      end
    end

    def log(m)
      log = "#{Time.zone.now} - #{m}"
      log_job_execution_step.log_line(log)
      puts log
    end

  private

    def import_google_csv
      drive = @google_drive || Import::GoogleDrive.new
      folder_id = task_config["folder_id"]
      file_list = drive.list_files(folder_id: folder_id)
      truncate_data = truncate_before_load?
      file_list.files.each do |file|
        if file.mime_type == "text/csv"
          csv = drive.csv(file_id: file.id, header_converters: HEADER_CONVERTER)
          if csv
            import_csv_data(csv, truncate_data: truncate_data)
          else
            log "Failed opening workbook! File id: #{file.id}"
          end
        else
          log "Skipping Non CSV file! File id: #{file.name}"
        end
        truncate_data = false # only truncate before the first file
      end
    end

    def import_csv_data(csv, truncate_data: truncate_before_load?)
      headers = csv.first.headers.map(&:to_s)
      csv.rewind
      warn_unmatched_headers(headers)

      n_errors = 0
      success = true
      ActiveRecord::Base.transaction do
        truncate if truncate_data

        records = []

        loop do
          if n_errors >= max_errors
            log "Too many errors #{n_errors}, exiting!"
            records = []
            success = false
            break
          end

          row = csv.shift
          break unless row

          row_hash = row.to_h.transform_keys { |key| key.to_sym if key.present? }
          next if row_hash.values.uniq.count == 0 && row_hash.values[0].blank?

          row_error = false
          attributes = {}

          errors = column_mappings_to_attributes(headers: headers, attributes: attributes, row_hash: row_hash)
          if errors.positive?
            n_errors += errors
            row_error = true
          end

          next if row_error

          # puts "attributes=#{attributes.inspect}"
          attributes[:institution_id] = institution_id if has_institution_id?
          records << class_name.new(attributes)

          if records.size >= batch_size
            n_errors += import_records(records)
            records = []
          end

        rescue CSV::MalformedCSVError => e
          n_errors += 1
          log "skipping bad row - MalformedCSVError: #{e.message}"
        end # loop

        csv.close

        unless records.empty?
          n_errors += import_records(records)
          records = []
        end

        if n_errors >= max_errors
          log "Too many errors #{n_errors}."
          success = false
        else
          log "Finished importing #{class_name.model_name.human}."
        end

        raise ActiveRecord::Rollback, "Rolling back the upload." unless success
      end # ActiveRecord::Base.transaction

      success
    end

    def import_google_sheet
      drive = @google_drive || Import::GoogleDrive.new
      file_id = task_config["file_id"]
      workbook = drive.workbook(file_id: file_id)
      if workbook
        import_worksheet(workbook[sheet_name])
      else
        log "Failed opening workbook! File id: #{file_id}"
      end
    end

    def import_worksheet(worksheet, truncate_data: truncate_before_load?)
      headers = worksheet_headers(worksheet)
      warn_unmatched_headers(headers)
      n_errors = 0
      success = true
      ActiveRecord::Base.transaction do
        truncate if truncate_data

        records = []

        ((header_rows_to_skip + 1)..worksheet.count).each do |row_number|
          if n_errors >= max_errors
            log "Too many errors #{n_errors}, exiting!"
            records = []
            success = false
            break
          end

          row = worksheet[row_number]
          break unless row

          row_hash = worksheet_row_to_hash(row, headers)

          next if row_hash.values.uniq.count == 0 || (row_hash.values.uniq.count == 1 && row_hash.values[0].blank?)

          row_error = false
          attributes = {}

          errors = column_mappings_to_attributes(headers: headers, attributes: attributes, row_hash: row_hash)
          if errors.positive?
            n_errors += errors
            row_error = true
          end

          next if row_error

          # puts "attributes=#{attributes.inspect}"
          attributes[:institution_id] = institution_id if has_institution_id?
          records << class_name.new(attributes)

          if records.size >= batch_size
            n_errors += import_records(records)
            records = []
          end

        rescue StandardError => e
          n_errors += 1
          log "skipping bad row - Error: #{e.message}"
        end # loop

        unless records.empty?
          n_errors += import_records(records)
          records = []
        end

        if n_errors >= max_errors
          log "Too many errors #{n_errors}."
          success = false
        else
          log "Finished importing #{class_name.model_name.human}."
        end

        raise ActiveRecord::Rollback, "Rolling back the upload." unless success
      end # ActiveRecord::Base.transaction

      success
    end

    def validate_and_parse_value(val, column_name, row)
      raise StandardError, "Invalid integer [#{val}] in column: #{column_name} row: #{row.to_h}" if class_name.columns_hash[column_name].type == :integer && !Util.valid_integer?(val)
      if class_name.columns_hash[column_name].type == :datetime && !(val.class == DateTime || Util.valid_datetime?(val))
        raise StandardError, "Invalid datetime [#{val}] in column: #{column_name} row: #{row.to_h}"
      end
      if class_name.columns_hash[column_name].type == :date && !(val.class == DateTime || Util.valid_datetime?(val))
        raise StandardError, "Invalid date [#{val}] in column: #{column_name} row: #{row.to_h}"
      end

      val = Util.parse_datetime(val) if class_name.columns_hash[column_name].type == :datetime && val.class != DateTime

      val
    end

    def column_mappings
      task_config["column_mappings"] || {}
    end

    def column_mapping_fields
      return @mapping_fields if @mapping_fields.present?
      @mapping_fields = column_mappings.values.map do |mapping|
        fields = mapping.scan(/(?<=\%\{)[^}]*(?=\})/)
        fields.map { |value| value.lstrip.chomp }
      end
      @mapping_fields = @mapping_fields.flatten.uniq
    end

    def worksheet_headers(worksheet)
      headers = convert_row_to_values(worksheet[header_rows_to_skip])
      headers.map { |header| Util.column_to_attribute(header) }
    end

    def worksheet_row_to_hash(row, headers)
      hash = {}
      headers.each_with_index do |header, idx|
        hash[header.to_sym] = if row[idx].present?
                                row[idx].value
                              end
      end
      hash
    end

    def header_rows_to_skip
      task_config["header_rows_to_skip"] || 0
    end

    def sheet_name
      task_config["sheet_name"] || 0 # by default just get the first sheet if none named
    end

    def convert_row_to_values(row)
      values = []
      (0..row.size - 1).each do |i|
        break if row[i].blank? || row[i].value.blank?
        values << row[i].value
      end
      values
    end

    def warn_unmatched_headers(headers)
      unmatched_columns = (headers - column_mapping_fields).select { |column_name| class_name.columns_hash[column_name].blank? }
      log "!!WARNING!!: These columns are not processed: [#{unmatched_columns.join(', ')}]" if unmatched_columns.present?
    end

    def column_mappings_to_attributes(headers:, attributes:, row_hash:)
      errors = 0

      headers.each do |column_name|
        next if class_name.columns_hash[column_name].blank?
        val = row_hash[column_name.to_sym]
        begin
          value = validate_and_parse_value(val, column_name, row_hash)
          attributes[column_name] = value
        rescue StandardError => error
          log error.message
          errors += 1
        end
      end
      column_mappings.each do |column_name, template|
        next if class_name.columns_hash[column_name].blank?
        begin
          value = template % row_hash
          value = validate_and_parse_value(value, column_name, row_hash)
          attributes[column_name] = value
        rescue StandardError => error
          log error.message
          errors += 1
        end
      end
      errors
    end
  end # class Task
end
# rubocop:enable Metrics/ClassLength
