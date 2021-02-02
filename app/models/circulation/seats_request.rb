# frozen_string_literal: true
class Circulation::SeatsRequest < Circulation::Base
  class << self
    def gather_data(date_range: )
      values = Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).group_by_day(:from).count
      combined_values = combine_values(values)
      combined_values.values.sort_by { |a| a[:name] }
    end

    def gather_status_data(date_range:)
      Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).count
    end

    def gather_tabular_data(date_range:)
      values = Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).group_by_week(:from, week_start: :monday).count
      combine_tabular_values(values)      
    end

    def colors_for_status_data(data:)
      data.keys.map(&:first).uniq.map { |location| color_for_location(location) }
    end

    def color_for_status_and_location(status, location)
      color_idx = if status == "Confirmed"
                    0
                  elsif status.starts_with?("Cancelled")
                    1
                  else
                    2
                  end
      color_for_location(location, color_idx: color_idx)
    end

    private

    def combine_values(values)
      combined_values = {}
      values.each do |key, value|
        location = key[0]
        status = db_to_status(key[1])
        location_status = "#{location}, #{status}"
        day = key[2]
        combined_values[location_status] ||= { name: location_status, data: {}, stack: location, color: color_for_status_and_location(status, location) }
        current_value = combined_values[location_status][:data][day] || 0
        combined_values[location_status][:data][day] = current_value + value
      end
      combined_values
    end

    def combine_tabular_values(values)
      combined_values = {}
      values.each do |key, value|
        location = key[0]
        status = db_to_status(key[1])
        day = key[2]
        combined_values[day] ||= { }
        combined_values[day][location] ||= { "Confirmed" => 0, "Cancelled" => 0  }
        current_value = combined_values[day][location][status] || 0
        combined_values[day][location][status] = current_value + value
      end
      combined_values
    end

    def db_to_status(db_status)
      if db_status.starts_with?("Cancelled")
        "Cancelled"
      elsif db_status == "Mediated Approved"
        "Confirmed"
      else
        db_status
      end
    end
  end
end
