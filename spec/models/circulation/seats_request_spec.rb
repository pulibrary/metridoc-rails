# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe Circulation::SeatsRequest, type: :model do
  let(:a_week_ago) { 1.week.ago.beginning_of_week }
  let(:two_weeks_ago) { 2.weeks.ago.beginning_of_week }

  describe "#gather_data" do
    it "gathers no data for an empty range" do
      expect(described_class.gather_data(date_range: a_week_ago..1.week.ago.end_of_week)).to eq([])
    end

    it "gathers data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by patron")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      expect(described_class.gather_data(date_range: a_week_ago..1.week.ago.end_of_week)).to eq(
        [{ color: "#000000", data: { a_week_ago.to_date => 2 }, name: "Firestone, Cancelled", stack: "Firestone" },
         { color: "#000000", data: { a_week_ago.to_date => 3 }, name: "Firestone, Confirmed", stack: "Firestone" },
         { color: "#000000", data: { a_week_ago.to_date => 1 }, name: "Lewis, Confirmed", stack: "Lewis" }]
      )
    end
  end

  describe "#gather_status_data" do
    it "gathers no data for an empty range" do
      expect(described_class.gather_status_data(date_range: a_week_ago..1.week.ago.end_of_week)).to eq({})
    end

    it "gathers data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by patron")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      expect(described_class.gather_status_data(date_range: a_week_ago..1.week.ago.end_of_week)).to eq(
        { ["Firestone", "Cancelled by other"] => 1,
          ["Firestone", "Cancelled by patron"] => 1,
          ["Firestone", "Confirmed"] => 3,
          ["Lewis", "Confirmed"] => 1 }
      )
    end
  end

  describe "#gather_tabular_data" do
    it "gathers no data for an empty range" do
      expect(described_class.gather_tabular_data).to eq({})
    end

    it "gathers data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed", checked_in: two_weeks_ago, checked_out: two_weeks_ago)
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed", checked_in: a_week_ago)
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by User (Cancelled by Patron)")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      expect(described_class.gather_tabular_data(previous_weeks: 2)).to eq(
        { a_week_ago.to_date => { "Firestone" => { "Cancelled" => 1, "Cancelled by Admin" => 1, "Confirmed" => 3, "Checked In" => 1, "% Checked In/Confirmed" => "33%", "Checked Out" => 0, "Other" => 0 }, "Lewis" => { "Cancelled" => 0, "Cancelled by Admin" => 0, "Confirmed" => 1, "Checked In" => 0, "% Checked In/Confirmed" => "0%", "Checked Out" => 0, "Other" => 0 } },
          two_weeks_ago.to_date => { "Firestone" => { "Cancelled" => 0, "Cancelled by Admin" => 0, "Confirmed" => 1, "Checked In" => 1, "% Checked In/Confirmed" => "100%", "Checked Out" => 1, "Other" => 0 }, "Lewis" => { "Cancelled" => 0, "Cancelled by Admin" => 0, "Confirmed" => 1, "Checked In" => 0, "% Checked In/Confirmed" => "0%", "Checked Out" => 0, "Other" => 0 } } }
      )
    end
  end

  describe "#write_tabular_data" do
    let(:sheet_service) { instance_double("Google::Apis::SheetsV4::SheetsService", authorization: auth) }
    let(:auth) { instance_double("Signet::OAuth2::Client", fetch_access_token!: true) }
    let(:file_id) { "1wNNrEVkDc6cLic7K6j5CYsQercm9vRMdQMY" }
    let(:sheet) { Circulation::GoogleSheet.new(sheet_service: sheet_service, authorization: auth) }

    before do
      expect(sheet_service).to receive(:authorization=).with(auth)
    end

    it "writes no data for an empty range" do
      expect(described_class.write_tabular_data(file_id: 'abc123', sheet: sheet)).to eq(true)
    end

    it "writes data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed", checked_in: two_weeks_ago, checked_out: two_weeks_ago)
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed", checked_in: a_week_ago)
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by User (Cancelled by Patron)")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      sheet_data = [["Location", "Confirmed", "Cancelled", "Cancelled by Admin", "Checked In", "Checked Out", "Other", "% Checked In/Confirmed"],
                    [a_week_ago.to_date, "", "", "", "", "", "", ""],
                    ["Firestone", 3, 1, 1, 1, 0, 0, "33%"],
                    ["Lewis", 1, 0, 0, 0, 0, 0, "0%"],
                    [two_weeks_ago.to_date, "", "", "", "", "", "", ""],
                    ["Firestone", 1, 0, 0, 1, 1, 0, "100%"],
                    ["Lewis", 1, 0, 0, 0, 0, 0, "0%"]]
      expect(sheet).to receive(:add_data).with(file_id: 'abc123', data: sheet_data, range: 'Sheet1!A1:H7').and_return(true)
      expect(described_class.write_tabular_data(file_id: 'abc123', previous_weeks: 2, sheet: sheet)).to eq(true)
    end
  end
end
# rubocop:enable RSpec/ExampleLength
