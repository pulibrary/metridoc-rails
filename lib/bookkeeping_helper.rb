# frozen_string_literal: true
module BookkeepingHelper
  class << self
    def update_bookkeeping_table(config_folder, from_date, to_date)
      to_date &&= Date.parse(to_date)
      from_date &&= Date.parse(from_date)
      table = Bookkeeping::DataLoad.find_by(table_name: config_folder)
      if table.nil?
        table = Bookkeeping::DataLoad.new(table_name: config_folder, earliest: from_date.to_s, latest: to_date.to_s)
      else
        table.earliest = from_date.to_s unless from_date.nil? || from_date > table.earliest.to_date
        table.latest = to_date.to_s unless to_date.nil? || to_date < table.latest.to_date
      end
      table.save!
    end
  end
end
