# frozen_string_literal: true
require 'rake'
require 'optparse'

namespace "transfer_results" do
  desc "Transfer seats results from this system to an external location"
  task seats: :environment do |_t, _args|
    file_id = ENV["SEAT_FILE_ID"]
    if file_id.blank?
      puts "Seat File ID must be present.  Run with SEAT_FILE_ID=123456 rake transfer_results:seats"
      return false
    end
    sheet_name = ENV["SEAT_SHEET_NAME"] || "Sheet1"
    previous_weeks = ENV["SEAT_PREVIOUS_WEEKS"] || 10
    Circulation::SeatsRequest.write_tabular_data(file_id: file_id, previous_weeks: previous_weeks.to_i, sheet_name: sheet_name)
  end
end
