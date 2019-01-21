module Export
  module Mssql

    class Main
      def initialize(options = {})
        @options = options
        require 'dotenv'
        Dotenv.load(File.join(root_path, ".env"))

        raise "Config Folder not specified." if config_folder.blank?
        raise "Config Folder [#{config_folder}] doesn't exist." unless Dir.exist?(File.join(root_path, "config", "data_sources", config_folder))
      end

      def config_folder
        @options[:config_folder]
      end

      def root_path
        File.expand_path('../../..', File.dirname(__FILE__))
      end

      def test_mode?
        return @test_mode unless @test_mode.nil?
        @test_mode = @options[:test_mode].upcase.strip == "TRUE" rescue false
      end

      def execute(sequences_only = [])
        log_job_execution
        return #TODO testing

        task_files(sequences_only).each do |task_file|
          t = Task.new(self, task_file)
          next unless t.source_adapter == 'mssql'
          return false unless t.execute
        end

        return true
      end

      def task_files(sequences_only = [])
        sequences_only = [sequences_only] if sequences_only.present? && !sequences_only.is_a?(Array)

        full_paths = Dir[ File.join(root_path, "config", "data_sources", config_folder, "**", "*")]
        tasks = []
        full_paths.each do |full_path|
          next if File.basename(full_path) == "global.yml"

          table_params = YAML.load_file(full_path)
          seq = table_params["load_sequence"] || 0

          next if sequences_only.present? && !sequences_only.include?(seq)

          tasks << {load_sequence: seq, full_path: full_path}
        end

        tasks.sort_by{|t| t[:load_sequence]}.map{|t| t[:full_path]}
      end

      def global_config
        return @global_params unless @global_params.blank?

        global_params = {}

        yml_path = File.join(root_path, "config", "data_sources", config_folder, "global.yml")

        if File.exist?(yml_path)
          global_params = YAML.load(ERB.new(File.read(yml_path)).result)
        end

        @global_params = global_params.merge(@options.stringify_keys)
      end

      def db_opts
        opts = {    host:     global_config["host"],
                    port:     global_config["port"],
                    database: global_config["database"],
                    username: global_config["username"],
                    password: global_config["password"],
                    adapter:  'sqlserver',
                    pool:     5,
                    timeout:  120000 }
      end

      def mac_address
        platform = RUBY_PLATFORM.downcase
        output = `#{(platform =~ /win32/) ? 'ipconfig /all' : 'ifconfig'}`
        case platform
          when /darwin/
            $1 if output =~ /en1.*?(([A-F0-9]{2}:){5}[A-F0-9]{2})/im
          when /win32/
            $1 if output =~ /Physical Address.*?(([A-F0-9]{2}-){5}[A-F0-9]{2})/im
          # Cases for other platforms...
          else nil
        end
      end

      def log_job_execution
        return @log_job_execution if @log_job_execution.present?

        environment = ENV['RACK_ENV'] || 'development'
        dbconfig = YAML.load(File.read(File.join(root_path, 'config', 'database.yml')))

        klass = Object.const_set("LogJobExecution", Class.new(ActiveRecord::Base))
        klass.table_name = "log_job_executions"
        klass.establish_connection dbconfig[environment]

        global_yml = global_config
        global_yml["username"] = "***"
        global_yml["password"] = "***"

        log_job_execution = klass.new
        log_job_execution.source_name = folder
        log_job_execution.job_type = 'import'
        log_job_execution.global_yml = global_yml
        log_job_execution.mac_address = mac_address
        log_job_execution.started_at = Time.now
        log_job_execution.status = 'running'
        log_job_execution.save!

        @log_job_execution = log_job_execution

        return @log_job_execution
      end

    end

  end
end
