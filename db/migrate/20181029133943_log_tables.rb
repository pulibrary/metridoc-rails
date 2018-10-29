class LogTables < ActiveRecord::Migration[5.1]
  def change

    create_table :job_logs do |t|
      t.string   :job_name, null: false
      t.string   :environment, null: false
      t.string   :mac_address, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.string   :status, null: false
    end

    create_table :job_step_log do |t|
      t.belongs_to :job_log, null: false, index: true
      t.string     :step, null: false
      t.datetime   :log_date, null: false
      t.text       :log_text, null: false
    end

  end
end
