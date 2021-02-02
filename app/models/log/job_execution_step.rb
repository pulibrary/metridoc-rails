# frozen_string_literal: true
module Log
  class JobExecutionStep < ApplicationRecord
    self.table_name_prefix = 'log_'

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
      step_yml.map { |key, val| step_yml[key] = (/password/i.match?(key) ? "[FILTERED]" : val) }
    end
  end
end
