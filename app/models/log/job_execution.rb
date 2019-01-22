class Log::JobExecution < Log::Base
  has_many :job_execution_steps

  before_validation :set_defaults

  def set_status!(status)
    self.status = status
    save!
  end

  def log_line(line)
    self.log_text = (self.log_text.present? ? self.log_text + "\n" : "") + line
    save!
  end

  private
  def set_defaults
    self.status_set_at = Time.now if status_changed?
  end

end
