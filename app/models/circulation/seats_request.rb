# frozen_string_literal: true
class Circulation::SeatsRequest < Circulation::Base
  def self.gather_data(date_range:)
    values = Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).group_by_day(:from).count
    combined_values = {}
    values.each do |key, value|
      location = key[0]
      status = key[1].starts_with?("Cancelled") ? "Cancelled" : key[1]
      status = "Confirmed" if status == "Mediated Approved"
      location_status = "#{location}, #{status}"
      day = key[2]
      combined_values[location_status] ||= { name: location_status, data: {}, stack: location, color: color_for_status_and_location(status, location) }
      current_value = combined_values[location_status][:data][day] || 0
      combined_values[location_status][:data][day] = current_value + value
    end
    combined_values.values.sort_by { |a| a[:name] }
  end

  def self.gather_status_data(date_range:)
    Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).count
  end

  def self.colors_for_status_data(data:)
    data.keys.map(&:first).uniq.map { |location| color_for_location(location) }
  end

  def self.color_for_status_and_location(status, location)
    color_idx = if status == "Confirmed"
                  0
                elsif status.starts_with?("Cancelled")
                  1
                else
                  2
                end
    color_for_location(location, color_idx: color_idx)
  end
end
