# frozen_string_literal: true
class Circulation::SeatsRequest < Circulation::Base
  class << self
    def gather_data(date_range:)
      values = Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).group_by_day(:from).count
      combined_values = combine_values(values)
      combined_values.values.sort_by { |a| a[:name] }
    end

    def gather_status_data(date_range:)
      Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).count
    end

    def gather_tabular_data(previous_weeks: 1)
      combined_values = {}
      (1..previous_weeks).each do |week_ago|
        date = week_ago.weeks.ago.beginning_of_week
        date_range = week_ago.weeks.ago.beginning_of_week..week_ago.weeks.ago.end_of_week
        values = Circulation::SeatsRequest.where(from: date_range).order(:location).group(:location).group(:status).pluck(:location, :status, Arel.sql("Count(status)"), Arel.sql("Count(checked_in)"), Arel.sql("Count(checked_out)"))

        combined_values = combine_tabular_values(date: date, values: values, combined_values: combined_values)
      end
      combined_values
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

    def write_tabular_data(file_id:, sheet_name: 'Sheet1', previous_weeks: 10, sheet: Circulation::GoogleSheet.new)
      data = gather_tabular_data(previous_weeks: previous_weeks)
      return true if data.blank?

      sheet_data = [["Location"] + data.values.first.values.first.keys + ['Other']]
      data.each do |key, location_data|
        sheet_data << [key, "", "", "", "", ""]
        location_data.each do |location, statuses|
          sheet_data << [location] + statuses.values
        end
      end
      range = "#{sheet_name}!A1:#{convert_to_alpha(sheet_data.first.count)}#{sheet_data.count}"
      sheet.add_data(file_id: file_id, data: sheet_data, range: range)
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

    def combine_tabular_values(date:, values:, combined_values:)
      values.each do |key|
        location = key[0]
        status = db_to_tabular_status(key[1])
        value = key[2]
        checked_in = key[3]
        checked_out = key[4]
        day = date.to_date
        combined_values[day] ||= {}
        combined_values[day][location] ||= { "Confirmed" => 0, "Cancelled" => 0, "Cancelled by Admin" => 0, "Checked In" => 0, "Checked Out" => 0 }
        current_value = combined_values[day][location][status] || 0
        combined_values[day][location][status] = current_value + value
        combined_values[day][location]["Checked In"] += checked_in
        combined_values[day][location]["Checked Out"] += checked_out
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

    def db_to_tabular_status(db_status)
      if db_status == "Cancelled by User (Cancelled by Patron)"
        "Cancelled"
      elsif db_status.starts_with?("Cancelled")
        "Cancelled by Admin"
      elsif db_status == "Mediated Approved"
        "Confirmed"
      else
        db_status
      end
    end

    def convert_to_alpha(number)
      @letter_array ||= ('A'..'ZZZ').to_a
      @letter_array[number - 1]
    end
  end
end
