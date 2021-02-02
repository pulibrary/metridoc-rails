# frozen_string_literal: true
require '../../../app/models/log/job_execution_step.rb'
require '../../../app/models/bookkeeping/data_load.rb'

require 'csv'

module Export
  module Mssql
    class Task
      def initialize(main_driver, task_file)
        @main_driver = main_driver
        @task_file = task_file
      end

      def task_config
        return @task_config if @task_config.present?
        @task_config = @main_driver.global_config.merge(YAML.safe_load(ERB.new(File.read(@task_file)).result))
      end

      def import_model_name
        "Import::#{task_config['target_model']}".gsub(/::/, '')
      end

      def import_model
        return import_model_name.constantize if begin
                                                   import_model_name.constantize
                                                rescue
                                                  nil
                                                 end
        klass = Object.const_set(import_model_name, Class.new(ApplicationRecord))
        klass.table_name = task_config['source_table']
        klass.establish_connection @main_driver.db_opts
        klass.primary_key = nil
        # TODO: handle multiple source_tables / break them into joins
        klass
      end

      def export_filter_date_sql
        task_config["export_filter_date_sql"]
      end

      def export_filter_date_range_sql
        task_config["export_filter_date_range_sql"]
      end

      def from_date
        @from_date.presence
        @from_date = nil
        @from_date = Date.parse(task_config["from_date"]) if task_config["from_date"].present?
        @from_date
      end

      def to_date
        @to_date.presence
        @to_date = nil
        @to_date = Date.parse(task_config["to_date"]) if task_config["to_date"].present?
        @to_date
      end

      def data
        scope = import_model.select(select_clause)
        scope = scope.distinct if task_config['select_distinct']
        scope = scope.from(from_raw) if from_raw.present?
        join_tables.each do |join_table|
          scope = scope.joins(join_table)
        end
        filters.each do |filter|
          scope = scope.where(filter)
        end

        raise "Ranged queries not supported in production mode.  Specify a from OR a to date." if export_filter_date_range_sql.present? && from_date.present? && to_date.present?

        if export_filter_date_sql.present? && from_date.present?
          validate_range_request('from')
          scope = scope.where(export_filter_date_sql, from_date)
        end

        if export_filter_date_range_sql.present? && to_date.present?
          validate_range_request('to')
          scope = scope.where(export_filter_date_range_sql, Date.today - 1.year, to_date)
        end

        scope = scope.group(group_by_columns) if group_by_columns.present?
        scope
      end

      def test_mode?
        @main_driver.test_mode?
      end

      def source_adapter
        task_config["source_adapter"]
      end

      def from_raw
        task_config["from_raw"]
      end

      def join_tables
        task_config["join_tables"] || []
      end

      def group_by_columns
        task_config["group_by_columns"] || []
      end

      def filters
        if task_config["filters"].present?
          return task_config["filters"]
        elsif task_config["filter_raw"].present?
          return [task_config["filter_raw"]]
        end
        []
      end

      def select_clause
        column_mappings.each.map { |k, v| "#{k} AS #{v}" }.join(", ")
      end

      def validate_range_request(req_type)
        environment = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
        dbconfig = YAML.safe_load(ERB.new(File.read(File.join(@main_driver.root_path, 'config', 'database.yml'))).result)
        Bookkeeping::DataLoad.establish_connection(dbconfig[environment])
        earliest = Bookkeeping::DataLoad.find_by(table_name: task_config['config_folder']).earliest.to_date
        if req_type == 'from'
          raise "From date cannot be greater than #{earliest}" unless from_date < earliest
        elsif req_type == 'to'
          raise "To date cannot be earlier than #{earliest}" if to_date < earliest
          raise "To date must be after #{Date.today - 1.year}" if to_date < Date.today - 1.year
        else
          raise 'Invalid range request type.  Please specify "from" or "to."'
        end
      end

      def update_bookkeeping_table
        environment = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
        dbconfig = YAML.safe_load(ERB.new(File.read(File.join(@main_driver.root_path, 'config', 'database.yml'))).result)
        Bookkeeping::DataLoad.establish_connection(dbconfig[environment])
        table = Bookkeeping::DataLoad.find_by(table_name: task_config['config_folder'])
        table.earliest = from_date.to_s unless from_date.nil? || from_date > table.earliest.to_date
        table.latest = to_date.to_s unless to_date.nil? || to_date < table.latest.to_date
        table.save!
      end

      def execute
        log_job_execution_step

        FileUtils.mkdir_p task_config["export_folder"]

        csv_file_path = File.join(task_config["export_folder"], task_config["export_file_name"].downcase)

        CSV.open(csv_file_path, "wb") do |csv|
          csv << column_mappings.map { |_k, v| v }

          data.each_with_index do |obj, i|
            csv << column_mappings.each_with_index.map { |(_k, v), _i| obj.send(v) }
            break if test_mode? && i >= 100
            puts "Processed #{i} records" if i > 0 && i % 10_000 == 0
          end
        end # CSV.open

        log_job_execution_step.set_status!("successful")
        true

      rescue => ex
        log "Error => [#{ex.message}]"
        log_job_execution_step.set_status!("failed")
        false
      end

      def column_mappings
        task_config['column_mappings']
      end

      def log_job_execution_step
        return @log_job_execution_step if @log_job_execution_step.present?

        environment = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
        dbconfig = YAML.safe_load(ERB.new(File.read(File.join(@main_driver.root_path, 'config', 'database.yml'))).result)
        Log::JobExecutionStep.establish_connection dbconfig[environment]

        @log_job_execution_step = Log::JobExecutionStep.create!(
                                                          job_execution_id: @main_driver.log_job_execution.id,
                                                          step_name: task_config["load_sequence"],
                                                          step_yml: task_config,
                                                          started_at: Time.zone.now,
                                                          status: 'running'
                                                        )
      end

      def log(m)
        log = "#{Time.zone.now} - #{m}"
        log_job_execution_step.log_line(log)
        puts log
      end
    end # class Task
  end
end
