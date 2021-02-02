require 'rails_helper'

RSpec.describe Import::GoogleDrive, type: :model do
  let(:drive_service) { instance_double("Google::Apis::DriveV3::DriveService", authorization: auth)}
  let(:auth) { instance_double("Signet::OAuth2::Client", fetch_access_token!: true) }
  let(:file_id) { "1wNNrEVkDc6cLic7K6j5CYsQercm9vRMdQMY"}
  let(:drive) { described_class.new(drive_service: drive_service, authorization: auth) }

  before do
    expect(drive_service).to receive(:authorization=).with(auth)
  end
  
  describe "#open_sheet" do
    it "Allows a sheet to be downloaded" do
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield("good result", false)
      drive.open_sheet(file_id: file_id) do |result, err|
        expect(result.class).to eq(String)
      end
    end

    it "captures errors with a bad file id" do
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield(nil, Google::Apis::ClientError.new("error"))
      drive.open_sheet(file_id: file_id) do |result, err|
        expect(result).to be_nil
        expect(err.class).to eq(Google::Apis::ClientError)
      end
    end    
  end

  describe "#workbook" do
    it "Allows a sheet to be downloaded" do
      data  = File.new(Rails.root.join('spec','fixtures',"FTF-STF Stats Architecture.xlsx")).read
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield(data, false)
      result = drive.workbook(file_id: file_id)
      expect(result.class).to eq(RubyXL::Workbook)
    end

    it "captures errors with a bad file id" do
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield(nil, Google::Apis::ClientError.new("error"))
      drive = described_class.new(drive_service: drive_service, authorization: auth)
      result = drive.workbook(file_id: file_id)
      expect(result).to be_nil
    end    
  end
end
