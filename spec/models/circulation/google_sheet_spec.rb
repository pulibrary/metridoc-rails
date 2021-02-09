# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Circulation::GoogleSheet, type: :model do
  let(:sheet_service) { instance_double("Google::Apis::SheetsV4::SheetsService", authorization: auth) }
  let(:auth) { instance_double("Signet::OAuth2::Client", fetch_access_token!: true) }
  let(:file_id) { "1wNNrEVkDc6cLic7K6j5CYsQercm9vRMdQMY" }
  let(:sheet) { described_class.new(sheet_service: sheet_service, authorization: auth) }
  # let(:sheet) { described_class.new}

  before do
    expect(sheet_service).to receive(:authorization=).with(auth)
  end

  describe "#add_data" do
    it "allows you to change a worksheet" do
      result = Google::Apis::SheetsV4::UpdateValuesResponse.new(updated_rows: 1)
      expect(sheet_service).to receive(:update_spreadsheet_value).with(file_id, "A1:B1", instance_of(Google::Apis::SheetsV4::ValueRange), hash_including(value_input_option: "RAW")).and_return(result)
      expect(sheet.add_data(file_id: file_id, data: [['abc', 'def']], range: 'A1:B1')).to be_truthy
    end

    it "notices if rows are not updated" do
      result = Google::Apis::SheetsV4::UpdateValuesResponse.new(updated_rows: 0)
      expect(sheet_service).to receive(:update_spreadsheet_value).with(file_id, "A1:B1", instance_of(Google::Apis::SheetsV4::ValueRange), hash_including(value_input_option: "RAW")).and_return(result)
      expect(sheet.add_data(file_id: file_id, data: [['abc', 'def']], range: 'A1:B1')).to be_falsey
    end

    it "handles an error" do
      expect(sheet_service).to receive(:update_spreadsheet_value).with(file_id, "A1:B1", instance_of(Google::Apis::SheetsV4::ValueRange), hash_including(value_input_option: "RAW")).and_raise(Google::Apis::ClientError.new("error"))
      expect(sheet.add_data(file_id: file_id, data: [['abc', 'def']], range: 'A1:B1')).to be_falsey
    end
  end
end
