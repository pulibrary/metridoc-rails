# frozen_string_literal: true
module Log
  class JobExecution < ApplicationRecord
    self.table_name_prefix = 'log_'

    has_many :job_execution_steps

    before_validation :set_defaults

    def set_status!(status)
      self.status = status
      save!
    end

    def log_line(line)
      self.log_text = (log_text.present? ? log_text + "\n" : "") + line
      save!
    end

    private

    def set_defaults
      self.status_set_at = Time.zone.now if status_changed?
      global_yml.map { |key, val| global_yml[key] = (/password/i.match?(key) ? "[FILTERED]" : val) }
    end
  end
end
